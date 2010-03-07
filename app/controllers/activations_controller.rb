class ActivationsController < ApplicationController
  before_filter :reset_user_session

  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    unless @user
      not_found; return
    end
    if @user.active?
      access_denied; return
    end
  end

  def create
    @user = User.find(params[:id])
   
    raise Exception if @user.active?
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
       
    if @user.activate!
      @user.deliver_activation_confirmation!
      flash[:notice] = t('user_session.account_activated')
      redirect_to user_url(@user.login)
    else
      render :action => :new
    end
  end

  private
  def reset_user_session
    current_user_session.destroy if current_user
    reset_session
  end

end
