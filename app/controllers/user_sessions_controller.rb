require 'httparty'
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  #before_filter :access_denied, :except => [:show, :new, :create, :destroy]
  ssl_allowed :show, :new, :create, :destroy
  
  def show
    if logged_in?
      redirect_to user_path(current_user.username)
    else
      redirect_to new_user_session_url
    end
  end
  
  def new
    @user_session = UserSession.new
    #case params[:login_form]
    #when 'password'
    #  render :partial => 'user_sessions/password'
    #when 'openid'
    #  render :partial => 'user_sessions/openid'
    #end
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    #flash[:login_form] = params[:login_form]
    @user_session.save do |result|
      save_return_to
      if result
        session[:locale] = @user_session.user.locale
        unless @user_session.user.active?
          flash[:notice] = t('user_session.your_account_is_suspended')
          render :action => :new
          @user_session.destroy
          return
        else
          flash[:notice] = t('user_session.logged_in')
          redirect_back_or_default user_url(@user_session.user.username)
          return
        end
      else
        flash[:notice] = t('user_session.login_failed')
        render :action => :new
        #redirect_to new_user_session_url
        #return
      end
    end

    unless performed?
      flash[:notice] = t('user_session.login_failed')
      render :action => :new
      #redirect_to new_user_session_url
    end
  end
  
  def destroy
    current_user_session.destroy
    save_return_to
    flash[:notice] = t('user_session.logged_out')
    redirect_back_or_default new_user_session_url
  end

  private
  def save_return_to
    return_to = session[:return_to]
    reset_session
    session[:return_to] = return_to
  end
end
