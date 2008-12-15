class UserCheckoutStatHasUsersController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'

  # GET /user_checkout_stat_has_users
  # GET /user_checkout_stat_has_users.xml
  def index
    @user_checkout_stat_has_users = UserCheckoutStatHasUser.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_checkout_stat_has_users }
    end
  end

  # GET /user_checkout_stat_has_users/1
  # GET /user_checkout_stat_has_users/1.xml
  def show
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_checkout_stat_has_user }
    end
  end

  # GET /user_checkout_stat_has_users/new
  # GET /user_checkout_stat_has_users/new.xml
  def new
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_checkout_stat_has_user }
    end
  end

  # GET /user_checkout_stat_has_users/1/edit
  def edit
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.find(params[:id])
  end

  # POST /user_checkout_stat_has_users
  # POST /user_checkout_stat_has_users.xml
  def create
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.new(params[:user_checkout_stat_has_user])

    respond_to do |format|
      if @user_checkout_stat_has_user.save
        flash[:notice] = 'UserCheckoutStatHasUser was successfully created.'
        format.html { redirect_to(@user_checkout_stat_has_user) }
        format.xml  { render :xml => @user_checkout_stat_has_user, :status => :created, :location => @user_checkout_stat_has_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_checkout_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_checkout_stat_has_users/1
  # PUT /user_checkout_stat_has_users/1.xml
  def update
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.find(params[:id])

    respond_to do |format|
      if @user_checkout_stat_has_user.update_attributes(params[:user_checkout_stat_has_user])
        flash[:notice] = 'UserCheckoutStatHasUser was successfully updated.'
        format.html { redirect_to(@user_checkout_stat_has_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_checkout_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_checkout_stat_has_users/1
  # DELETE /user_checkout_stat_has_users/1.xml
  def destroy
    @user_checkout_stat_has_user = UserCheckoutStatHasUser.find(params[:id])
    @user_checkout_stat_has_user.destroy

    respond_to do |format|
      format.html { redirect_to(user_checkout_stat_has_users_url) }
      format.xml  { head :ok }
    end
  end
end
