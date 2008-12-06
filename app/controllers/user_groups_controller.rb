class UserGroupsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_library, :only => :create
  require_role 'Administrator', :except => [:index, :show]

  # GET /user_groups
  # GET /user_groups.xml
  def index
    @user_groups = UserGroup.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @user_groups.to_xml }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.xml
  def show
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user_group.to_xml }
    end
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
  end

  # GET /user_groups/1;edit
  def edit
    @user_group = UserGroup.find(params[:id])
  end

  # POST /user_groups
  # POST /user_groups.xml
  def create
    UserGroup.transaction do
      @user_group = UserGroup.create(params[:user_group])
      #if @library
      #  @library.user_group << @user_group
      #end
    end

    respond_to do |format|
      if @user_group.save
        flash[:notice] = ('UserGroup was successfully created.')
        format.html { redirect_to user_group_url(@user_group) }
        format.xml  { head :created, :location => user_group_url(@user_group) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_group.errors.to_xml }
      end
    end
  end

  # PUT /user_groups/1
  # PUT /user_groups/1.xml
  def update
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      if @user_group.update_attributes(params[:user_group])
        flash[:notice] = ('UserGroup was successfully updated.')
        format.html { redirect_to user_group_url(@user_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_group.errors.to_xml }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.xml
  def destroy
    if params[:id] == 1
      access_denied
      return
    end

    @user_group = UserGroup.find(params[:id])
    @user_group.destroy

    respond_to do |format|
      format.html { redirect_to user_groups_url }
      format.xml  { head :ok }
    end
  end
end
