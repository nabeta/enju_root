class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :access_denied, :except => [:new, :create, :destroy]
  
  def new
    @user_session = UserSession.new
    case params[:mode]
    when 'password'
      render :partial => 'user_sessions/password'
    when 'openid'
      render :partial => 'user_sessions/openid'
    end
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        if @user_session.user.suspended?
          flash[:notice] = t('user_session.your_account_is_suspended')
          render :action => :new
          return
        else
          flash[:notice] = t('user_session.logged_in')
          redirect_back_or_default user_url(@user_session.user.login)
        end
      else
        flash[:notice] = t('user_session.login_failed')
        redirect_to new_user_session_url
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = t('user_session.logged_out')
    redirect_back_or_default new_user_session_url
    #session[:return_to] = nil
  end
end
