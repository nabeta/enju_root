class ActivationsController < ApplicationController
  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    access_denied unless @user
    access_denied if @user.active?
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

end
