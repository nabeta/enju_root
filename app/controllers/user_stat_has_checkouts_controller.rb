class UserStatHasCheckoutsController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'

  # GET /user_stat_has_checkouts
  # GET /user_stat_has_checkouts.xml
  def index
    @user_stat_has_checkouts = UserStatHasCheckout.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_stat_has_checkouts }
    end
  end

  # GET /user_stat_has_checkouts/1
  # GET /user_stat_has_checkouts/1.xml
  def show
    @user_stat_has_checkout = UserStatHasCheckout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_stat_has_checkout }
    end
  end

  # GET /user_stat_has_checkouts/new
  # GET /user_stat_has_checkouts/new.xml
  def new
    @user_stat_has_checkout = UserStatHasCheckout.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_stat_has_checkout }
    end
  end

  # GET /user_stat_has_checkouts/1/edit
  def edit
    @user_stat_has_checkout = UserStatHasCheckout.find(params[:id])
  end

  # POST /user_stat_has_checkouts
  # POST /user_stat_has_checkouts.xml
  def create
    @user_stat_has_checkout = UserStatHasCheckout.new(params[:user_stat_has_checkout])

    respond_to do |format|
      if @user_stat_has_checkout.save
        flash[:notice] = 'UserStatHasCheckout was successfully created.'
        format.html { redirect_to(@user_stat_has_checkout) }
        format.xml  { render :xml => @user_stat_has_checkout, :status => :created, :location => @user_stat_has_checkout }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_stat_has_checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_stat_has_checkouts/1
  # PUT /user_stat_has_checkouts/1.xml
  def update
    @user_stat_has_checkout = UserStatHasCheckout.find(params[:id])

    respond_to do |format|
      if @user_stat_has_checkout.update_attributes(params[:user_stat_has_checkout])
        flash[:notice] = 'UserStatHasCheckout was successfully updated.'
        format.html { redirect_to(@user_stat_has_checkout) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_stat_has_checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_stat_has_checkouts/1
  # DELETE /user_stat_has_checkouts/1.xml
  def destroy
    @user_stat_has_checkout = UserStatHasCheckout.find(params[:id])
    @user_stat_has_checkout.destroy

    respond_to do |format|
      format.html { redirect_to(user_stat_has_checkouts_url) }
      format.xml  { head :ok }
    end
  end
end
