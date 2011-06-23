# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  #before_filter :reset_params_session
  load_and_authorize_resource
  helper_method :get_patron
  before_filter :store_location, :only => [:index]
  before_filter :clear_search_sessions, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :user_sweeper, :only => [:create, :update, :destroy]
  #ssl_required :new, :edit, :create, :update, :destroy
  ssl_allowed :index, :show, :new, :edit, :create, :update, :destroy

  def index
    query = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = params[:query]
    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role

    unless query.blank?
      @users = User.search do
        fulltext query
        order_by sort[:sort_by], sort[:order]
        with(:required_role_id).less_than role.id
      end.results
    else
      @users = User.paginate(:all, :page => page, :order => "#{sort[:sort_by]} #{sort[:order]}")
    end
    @count[:query_result] = @users.total_entries
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users }
      format.pdf {
        prawnto :prawn => {
          :page_layout => :portrait,
          :page_size => "A4"},
        :inline => true
      }
    end
  end

  def show
    session[:user_return_to] = nil
    #@user = User.first(:conditions => {:username => params[:id]})
    #@user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.blank?
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end
    @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
    get_top_page_content

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user }
    end
  end

  def new
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.new
    #@user.openid_identifier = flash[:openid_identifier]
    prepare_options
    @user_groups = UserGroup.all
    get_patron
    if @patron.try(:user)
      flash[:notice] = t('page.already_activated')
      redirect_to @patron
      return
    end
    @user.patron_id = @patron.id if @patron
    @user.library = current_user.library
    @user.locale = current_user.locale
  end

  def edit
    #@user = User.first(:conditions => {:login => params[:id]})
    @user.role_id = @user.role.id

    prepare_options
  end

  def update
    @user.update_with_params(params[:user], current_user)
    if params[:user][:auto_generated_password] == "1"
      @user.set_auto_generated_password
      flash[:temporary_password] = @user.password
    end

    if current_user.has_role?('Administrator')
      if @user.role_id
        role = Role.find(@user.role_id)
        @user.role = role
      end
    end

    #@user.save do |result|
    respond_to do |format|
      if params[:user][:current_password].present? or params[:user][:password].present? or params[:user][:password_confirmation].present?
        @user.update_with_password(params[:user])
      else
        @user.save
      end
      if @user.errors.empty?
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user'))
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

    #unless performed?
    #  # OpenIDでの認証後
    #  flash[:notice] = t('user_session.login_failed')
    #  redirect_to edit_user_url(@user)
    #end

  end

  def create
    @user = User.create_with_params(params[:user], current_user)
    @user.set_auto_generated_password
    @user.role = Role.where(:name => 'User').first

    respond_to do |format|
      if @user.save
        #self.current_user = @user
        flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
        flash[:temporary_password] = @user.password
        format.html { redirect_to user_url(@user) }
        #format.html { redirect_to new_user_patron_url(@user) }
        format.xml  { head :ok }
      else
        prepare_options
        #flash[:notice] = ('The record is invalid.')
        flash[:error] = t('user.could_not_setup_account')
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    #@user = User.first(:conditions => {:username => params[:id]})
    #@user = User.find(params[:id])

    # 自分自身を削除しようとした
    if current_user == @user
      raise 'Cannot destroy myself'
      flash[:notice] = t('user.cannot_destroy_myself')
    end

    if @user.has_role?('Librarian')
      # 管理者以外のユーザが図書館員を削除しようとした。図書館員の削除は管理者しかできない
      unless current_user.has_role?('Administrator')
        raise 'Only administrators can destroy users'
        flash[:notice] = t('user.only_administrator_can_destroy')
      end
      # 最後の図書館員を削除しようとした
      if @user.last_librarian?
        raise 'This user is the last librarian in this system'
        flash[:notice] = t('user.last_librarian')
      end
    end

    # 最後の管理者を削除しようとした
    if @user.has_role?('Administrator')
      if Role.where(:name => 'Administrator').first.users.size == 1
        raise 'This user is the last administrator in this system'
        flash[:notice] = t('user.last_administrator')
      end
    end

    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  rescue
    access_denied
  end

  private
  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all_cache
    @languages = Language.all_cache
    if @user.active_for_authentication?
      @user.locked = '0'
    else
      @user.locked = '1'
    end
  end
end
