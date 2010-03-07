# http://github.com/rejeep/authlogic-password-reset-tutorial
class PasswordResetsController < ApplicationController
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!

      flash[:notice] = t('password_reset.instruction_sent')

      redirect_to root_path
    else
      flash[:error] = t('password_reset.not_found')

      render :action => :new
    end
  end

  def edit
  end

  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    if @user.save!
      flash[:notice] = t('password_reset.password_updated')
      UserSession.find.destroy

      redirect_to new_user_session_url
    else
      render :action => :edit
    end
  end


  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t('could_not_locate_account')

      redirect_to root_url
    end
  end

end
