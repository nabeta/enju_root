class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  #before_filter :login_required, :except => [:activate, :create]
  #before_filter :reset_params_session
  before_filter :login_required
  require_role 'Librarian', :only => [:index, :new, :create, :destroy]
  before_filter :suspended?
  before_filter :authorized_content, :only => [:edit, :update] # 上書き注意
  before_filter :store_location, :except => [:create, :update, :destroy]
  #cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # render new.rhtml
  def index
    query = params[:query] ||= nil
    #browse = nil
    order = nil
    @count = {}
    unless query.blank?
      @users = User.paginate_by_solr(query, :order => order, :page => params[:page], :per_page => @per_page).compact
      @count[:query_result] = @users.total_entries
      @query = query
    else
      @users = User.paginate(:all, :page => params[:page])
      @count[:query_result] = User.count_by_solr("[* TO *]")
    end
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users }
    end
  end

  def show
    session[:return_to] = nil
    session[:params] = nil
    @user = User.find(:first, :conditions => {:login => params[:id]})
    raise ActiveRecord::RecordNotFound unless @user
    @tags = @user.tags.find(:all, :order => 'tags.taggings_count DESC')

    @picked_up = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first)
    @news_feeds = LibraryGroup.find(:first).news_feeds.find(:all, :order => :position) rescue nil

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def new
    #@user = User.new
    @patron = Patron.find(params[:patron_id])
    @user_groups = UserGroup.find(:all, :order => :position)
    if @patron.user
      redirect_to patron_url(@patron)
      flash[:notice] = t('page.already_activated')
      return
    end
  rescue
    flash[:notice] = t('user.specify_patron')
    redirect_to patrons_url
  end

  def edit
    #@user = User.find(:first, :conditions => {:login => params[:id]})
    @user_groups = UserGroup.find(:all, :order => :position)
    @roles = Role.find(:all, :order => 'id desc')
    @libraries = Library.find(:all, :order => 'id')
    @user_role_id = @user.roles.first.id rescue nil
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def update
    #@user = User.find(:first, :conditions => {:login => params[:id]})
    User.transaction do
      if params[:user][:reset_url] == 'checkout_icalendar'
        @user.reset_checkout_icalendar_token
      elsif params[:user][:delete_url] == 'checkout_icalendar'
        @user.delete_checkout_icalendar_token
      end

      if current_user.has_role?('Administrator')
        if params[:user][:role_id]
          @user.roles.delete_all
          role = Role.find(params[:user][:role_id])
          @user.roles << role
        end
      end

      if params[:user][:auto_generated_password] == "1"
        @user.set_auto_generated_password if current_user.has_role?('Librarian')
      else
        unless params[:user][:old_password].blank?
          if @user.authenticated?(params[:user][:old_password])
            #@user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
            @user.password = params[:user][:password] if params[:user][:password]
            @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation]
            #begin
            #  @user.save!
            #  flash[:notice] = ('Successfully changed your password.')
            #rescue ActiveRecord::RecordInvalid => e
            #  flash[:error] = "Couldn't change your password: #{e}" 
            #  redirect_to :action => 'edit'
            #  return
            #end
            unless @user.password == @user.password_confirmation
              flash[:notice] = t('user.password_mismatch') unless @user.password == @user.password_confirmation
              redirect_to edit_user_url(@user.login)
              return
            end
          else
            flash[:notice] = t('user.wrong_password')
            redirect_to edit_user_url(@user.login)
            return
          end
        end
      end
      
      unless @user.expired_at.blank?
        begin
          expired_at = Time.zone.local(params[:user]["expired_at(1i)"], params[:user]["expired_at(2i)"], params[:user]["expired_at(3i)"])
        rescue
          flash[:notice] = t('page.invalid_date')
          redirect_to edit_user_url(@user.login)
          return
        end
      end

      @user.email = params[:user][:email] if params[:user][:email]
      @user.openid_url = params[:user][:openid_url] if params[:user][:openid_url]
      @user.share_bookmarks = params[:user][:share_bookmarks] if params[:user][:share_bookmarks]
      #@user.update_attributes(params[:user])
      if current_user.has_role?('Librarian')
        @user.suspended = params[:user][:suspended] || false
        @user.note = params[:user][:note]
        @user.user_group_id = params[:user][:user_id] ||= 1
        @user.library_id = params[:user][:library_id] ||= 1
        @user.required_role_id = params[:user][:required_role_id] ||= 1
        @user.expired_at = expired_at
        @user.keyword_list = params[:user][:keyword_list]
        @user.user_number = params[:user][:user_number]
      end
    end

    respond_to do |format|
      if @user.save
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user'))
        flash[:temporary_password] = @user.temporary_password if @user.temporary_password
        format.html { redirect_to user_url(@user.login) }
        format.xml  { head :ok }
      else
        @roles = Role.find(:all, :order => 'id desc')
        @libraries = Library.find(:all, :order => 'id')
        @user_groups = UserGroup.find(:all, :order => :position)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def create
    #@user = current_user
    #logout_keeping_session!
    #cookies.delete :auth_token
    expired_at = Time.zone.local(params[:user]["expired_at(1i)"], params[:user]["expired_at(2i)"], params[:user]["expired_at(3i)"]) rescue nil
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    #@user.password = params[:user][:password]
    #@user.password_confirmation = params[:user][:password_confirmation]
    @user.note = params[:user][:note]
    @user.user_group_id = params[:user][:user_group_id] ||= 1
    @user.library_id = params[:user][:library_id] ||= 1
    #@user.required_role_id = params[:user][:required_role_id] ||= 1
    @user.expired_at = expired_at
    @user.keyword_list = params[:user][:keyword_list]
    @user.user_number = params[:user][:user_number]
    @patron = Patron.find(params[:user][:patron_id])
    @user.patron = @patron
    success = @user && @user.save

    respond_to do |format|
      if success && @user.errors.empty?
        flash[:temporary_password] = @user.temporary_password
        @user.roles << Role.find(:first, :conditions => {:name => 'User'})
        @user.activate # TODO: すぐにアクティベーションするかは要検討
        #self.current_user = @user
        flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
        format.html { redirect_to user_url(@user.login) }
        format.xml  { head :ok }
      else
        @user_groups = UserGroup.find(:all, :order => :position)
        #flash[:notice] = ('The record is invalid.')
        flash[:error] = ("We couldn't set up that account, sorry.  Please try again, or contact an admin.")
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  #def activate
  #  self.current_user = User.find_by_activation_code(params[:activation_code])
  #  if logged_in? && !current_user.activated?
  #    current_user.activate
  #    flash[:notice] = ('Signup complete!')
  #  end
  #  redirect_back_or_default('/')
  #end

  def destroy
    # idが1のユーザは削除できない
    raise if params[:id] == 1

    # ユーザ削除には図書館員以上の権限が必要
    raise unless current_user.has_role?('Librarian')

    @user = User.find(:first, :conditions => {:login => params[:id]})

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
      if Role.find(:first, :conditions => {:name => 'Librarian'}).users.size == 1
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
      cookies.delete :auth_token
      reset_session
      access_denied
    end
  end

  def authorized_content
    @user = User.find(:first, :conditions => {:login => params[:id]})
    raise ActiveRecord::RecordNotFound if @user.nil?
    return true if current_user == @user
    return true if current_user.has_role?('Librarian')
    access_denied; return
  rescue ActiveRecord::RecordNotFound
    not_found
  end
end
