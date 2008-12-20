class ReserveStatHasUsersController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'

  # GET /reserve_stat_has_users
  # GET /reserve_stat_has_users.xml
  def index
    @reserve_stat_has_users = ReserveStatHasUser.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reserve_stat_has_users }
    end
  end

  # GET /reserve_stat_has_users/1
  # GET /reserve_stat_has_users/1.xml
  def show
    @reserve_stat_has_user = ReserveStatHasUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reserve_stat_has_user }
    end
  end

  # GET /reserve_stat_has_users/new
  # GET /reserve_stat_has_users/new.xml
  def new
    @reserve_stat_has_user = ReserveStatHasUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reserve_stat_has_user }
    end
  end

  # GET /reserve_stat_has_users/1/edit
  def edit
    @reserve_stat_has_user = ReserveStatHasUser.find(params[:id])
  end

  # POST /reserve_stat_has_users
  # POST /reserve_stat_has_users.xml
  def create
    @reserve_stat_has_user = ReserveStatHasUser.new(params[:reserve_stat_has_user])

    respond_to do |format|
      if @reserve_stat_has_user.save
        flash[:notice] = 'ReserveStatHasUser was successfully created.'
        format.html { redirect_to(@reserve_stat_has_user) }
        format.xml  { render :xml => @reserve_stat_has_user, :status => :created, :location => @reserve_stat_has_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reserve_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserve_stat_has_users/1
  # PUT /reserve_stat_has_users/1.xml
  def update
    @reserve_stat_has_user = ReserveStatHasUser.find(params[:id])

    respond_to do |format|
      if @reserve_stat_has_user.update_attributes(params[:reserve_stat_has_user])
        flash[:notice] = 'ReserveStatHasUser was successfully updated.'
        format.html { redirect_to(@reserve_stat_has_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reserve_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserve_stat_has_users/1
  # DELETE /reserve_stat_has_users/1.xml
  def destroy
    @reserve_stat_has_user = ReserveStatHasUser.find(params[:id])
    @reserve_stat_has_user.destroy

    respond_to do |format|
      format.html { redirect_to(reserve_stat_has_users_url) }
      format.xml  { head :ok }
    end
  end
end
