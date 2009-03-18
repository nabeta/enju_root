class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :access_denied, :except => [:new, :create, :destroy]
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t('user_session.logged_in')
      redirect_back_or_default user_url(@user_session.user.login)
    else
      if self.current_user.suspended?
        flash[:notice] = t('user_session.your_account_is_suspended')
      end
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = t('user_session.logged_out')
    redirect_back_or_default new_user_session_url
  end
end
