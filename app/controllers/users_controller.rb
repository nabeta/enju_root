# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  #before_filter :reset_params_session
  before_filter :has_permission?
  before_filter :suspended?
  before_filter :get_patron, :only => :new
  before_filter :store_location, :only => [:index, :show]
  before_filter :clear_manifestation_ids, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  #cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  #ssl_required :new, :edit, :create, :update, :destroy
  ssl_allowed :index, :show, :new, :edit, :create, :update, :destroy

  def index
    query = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'login'
      sort[:sort_by] = 'login'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = params[:query]
    page = params[:page] || 1
    role = current_user.try(:highest_role) || Role.find(1)

    unless query.blank?
      begin
        @users = User.search do
          fulltext query
          order_by sort[:sort_by], sort[:order]
          with(:required_role_id).less_than role.id+1
        end.results
      rescue RSolr::RequestError
        @users = WillPaginate::Collection.create(1,1,0) do end
      end
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
    session[:return_to] = nil
    session[:params] = nil
    @user = User.find(:first, :conditions => {:login => params[:id]})
    #@user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.blank?
    unless @user.patron
      redirect_to new_user_patron_url(@user.login); return
    end
    #@tags = @user.owned_tags_by_solr
    @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse

    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil
    @news_feeds = Rails.cache.fetch('NewsFeed.all'){NewsFeed.all}

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def new
    if logged_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.new
    @user.openid_identifier = flash[:openid_identifier]
    #@user_groups = UserGroup.find(:all)
    @user_groups = Rails.cache.fetch('UserGroup.all'){UserGroup.find(:all)}
    begin
      if @patron.user
        redirect_to patron_url(@patron)
        flash[:notice] = t('page.already_activated')
        return
      end
    rescue
      nil
    end
    @user.patron_id = @patron.id if @patron
    @user.expired_at = LibraryGroup.site_config.valid_period_for_new_user.days.from_now
  end

  def edit
    #@user = User.find(:first, :conditions => {:login => params[:id]})
    if current_user.has_role?('Librarian')
      @user = User.find(:first, :conditions => {:login => params[:id]})
    else
      @user = current_user
    end
    raise ActiveRecord::RecordNotFound if @user.blank?
    @user_role_id = @user.roles.first.id

    if params[:mode] == 'feed_token'
      if params[:disable] == 'true'
        @user.delete_checkout_icalendar_token
      else
        @user.reset_checkout_icalendar_token
      end
      render :partial => 'users/feed_token'
      return
    end
    prepare_options

  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def update
    #@user = User.find(:first, :conditions => {:login => params[:id]})
    if current_user.has_role?('Librarian')
      @user = User.find(:first, :conditions => {:login => params[:id]})
    else
      @user = current_user
    end
    @user.operator = current_user
    if @user != current_user
       if !current_user.has_role?('Librarian')
         access_denied; return
       end
    end

    if params[:user]
      #@user.login = params[:user][:login]
      @user.email = params[:user][:email]
      @user.old_password = params[:user][:old_password]
      @user.openid_identifier = params[:user][:openid_identifier]
      @user.keyword_list = params[:user][:keyword_list]
      @user.checkout_icalendar_token = params[:user][:checkout_icalendar_token]
      #@user.note = params[:user][:note]
      if @user.old_password.present?
        unless @user.valid_password?(@user.old_password)
          @user.password_not_verified = true unless current_user.has_role?('Administrator')
        end
      end
      if params[:user][:auto_generated_password] == "1"
        @user.reset_password if current_user.has_role?('Librarian')
      else
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
      end
    end

    if current_user.has_role?('Librarian')
      if params[:user]
        @user.suspended = params[:user][:suspended] || false
        @user.note = params[:user][:note]
        @user.user_group_id = params[:user][:user_group_id] ||= 1
        @user.library_id = params[:user][:library_id] ||= 1
        @user.role_id = params[:user][:role_id] ||= 1
        @user.required_role_id = params[:user][:required_role_id] ||= 1
        @user.user_number = params[:user][:user_number]
        @user.locale = params[:user][:locale]
        expired_at_array = [params[:user]["expired_at(1i)"], params[:user]["expired_at(2i)"], params[:user]["expired_at(3i)"]]
        begin
          @user.expired_at = Time.zone.parse(expired_at_array.join("-"))
        rescue
          flash[:notice] = t('page.invalid_date')
          redirect_to edit_user_url(@user.login)
          return
        end
      end
    end

    #@user.update_attributes(params[:user]) do |result|
    @user.save do |result|
      respond_to do |format|
        #if @user.update_attributes(params[:user])
        if result
          if current_user.has_role?('Administrator')
            if @user.role_id
              role = Role.find(@user.role_id)
              @user.set_role(role)
            end
          end

          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user'))
          flash[:temporary_password] = @user.password
          format.html { redirect_to user_url(@user.login) }
          format.xml  { head :ok }
        else
          prepare_options
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    unless performed?
      # OpenIDでの認証後
      flash[:notice] = t('user_session.login_failed')
      redirect_to edit_user_url(@user.login)
    end

  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def create
    if logged_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.new(params[:user])
    @user.operator = current_user
    if params[:user]
      #@user.login = params[:user][:login]
      @user.email = params[:user][:email]
      #@user.password = params[:user][:password]
      #@user.password_confirmation = params[:user][:password_confirmation]
      #@user.openid_identifier = params[:user][:openid_identifier]
      @user.note = params[:user][:note]
      @user.user_group_id = params[:user][:user_group_id] ||= 1
      @user.library_id = params[:user][:library_id] ||= 1
      @user.role_id = params[:user][:role_id] ||= 1
      @user.required_role_id = params[:user][:required_role_id] ||= 1
      @user.expired_at = Time.zone.local(params[:user]["expired_at(1i)"], params[:user]["expired_at(2i)"], params[:user]["expired_at(3i)"]) rescue nil
      @user.keyword_list = params[:user][:keyword_list]
      @user.user_number = params[:user][:user_number]
      @user.locale = params[:user][:locale]
    end
    # TODO: OpenIDで発行したアカウントへのパスワード通知
    #if params[:user][:auto_generated_password] == "1"
      #if @user.password.blank? and @user.password_confirmation.blank?
        @user.reset_password
      #end
    #end
    if @user.patron_id
      @user.patron = Patron.find(@user.patron_id) rescue nil
    end
              
    @user.activate

    @user.save do |result|
      respond_to do |format|
        if result
          flash[:temporary_password] = @user.password
          User.transaction do
            @user.roles << Role.find(:first, :conditions => {:name => 'User'})
          end
          #self.current_user = @user
          flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
          format.html { redirect_to user_url(@user.login) }
          #format.html { redirect_to new_user_patron_url(@user.login) }
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
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def destroy
    @user = User.find(:first, :conditions => {:login => params[:id]})
    #@user = User.find(params[:id])

    # 自分自身を削除しようとした
    if current_user == @user
      raise
      flash[:notice] = t('user.cannot_destroy_myself')
    end

    # 未返却の資料のあるユーザを削除しようとした
    if @user.checkouts.count > 0
      raise
      flash[:notice] = t('user.this_user_has_checked_out_item')
    end

    # 管理者以外のユーザが図書館員を削除しようとした。図書館員の削除は管理者しかできない
    if @user.has_role?('Librarian')
      unless current_user.has_role?('Administrator')
        raise
        flash[:notice] = t('user.only_administrator_can_destroy')
      end
    end

    # 最後の図書館員を削除しようとした
    if @user.has_role?('Librarian')
      if @user.last_librarian?
        raise
        flash[:notice] = t('user.last_librarian')
      end
    end

    # 最後の管理者を削除しようとした
    if @user.has_role?('Administrator')
      if Role.find(:first, :conditions => {:name => 'Administrator'}).users.size == 1
        raise
        flash[:notice] = t('user.last_administrator')
      end
    end

    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  rescue
    access_denied
  end

  private
  def suspended?
    if logged_in? and current_user.suspended?
      current_user_session.destroy
      access_denied
    end
  end

  def prepare_options
    #@user_groups = UserGroup.find(:all)
    @user_groups = Rails.cache.fetch('UserGroup.all'){UserGroup.all}
    @roles = Role.find(:all)
    @libraries = Library.find(:all)
    @languages = Rails.cache.fetch('Language.all'){Language.all}
  end

  def set_operator
    @user.operator = current_user
  end

  def last_request_update_allowed?
    true if %w[create update].include?(action_name)
  end

  def clear_manifestation_ids
    session[:manifestation_ids] = nil
  end
end
