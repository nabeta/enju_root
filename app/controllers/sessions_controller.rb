# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    if params[:login] == 'true'
      render :partial => 'sessions/new_login'
    end
  end

  def create
    return_to = session[:return_to]
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      reset_session
      self.current_user = user
      session[:return_to] = return_to

      if self.current_user.suspended?
        cookies.delete :auth_token
        flash[:notice] = t('session.your_account_is_suspended')
        redirect_back_or_default('/')
        return
      end

      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = t('session.logged_in')
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    redirect_back_or_default('/')
    logout_killing_session!
    flash[:notice] = t('session.logged_out')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = ("Couldn't log you in as '#{params[:login]}'")
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.zone.now}"
  end
end
