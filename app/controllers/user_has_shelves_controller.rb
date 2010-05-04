class UserHasShelvesController < ApplicationController
  load_and_authorize_resource
  before_filter :access_denied, :only => :new

  # GET /user_has_shelves
  # GET /user_has_shelves.xml
  def index
    @user_has_shelves = UserHasShelf.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_has_shelves }
    end
  end

  # GET /user_has_shelves/1
  # GET /user_has_shelves/1.xml
  def show
    @user_has_shelf = UserHasShelf.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_has_shelf }
    end
  end

  # GET /user_has_shelves/new
  # GET /user_has_shelves/new.xml
  def new
    @user_has_shelf = UserHasShelf.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_has_shelf }
    end
  end

  # GET /user_has_shelves/1/edit
  def edit
    @user_has_shelf = UserHasShelf.find(params[:id])
  end

  # POST /user_has_shelves
  # POST /user_has_shelves.xml
  def create
    @user_has_shelf = UserHasShelf.new(params[:user_has_shelf])

    respond_to do |format|
      if @user_has_shelf.save
        flash[:notice] = 'UserHasShelf was successfully created.'
        format.html { redirect_to(@user_has_shelf) }
        format.xml  { render :xml => @user_has_shelf, :status => :created, :location => @user_has_shelf }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_has_shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_has_shelves/1
  # PUT /user_has_shelves/1.xml
  def update
    @user_has_shelf = UserHasShelf.find(params[:id])

    respond_to do |format|
      if @user_has_shelf.update_attributes(params[:user_has_shelf])
        flash[:notice] = 'UserHasShelf was successfully updated.'
        format.html { redirect_to(@user_has_shelf) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_has_shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_has_shelves/1
  # DELETE /user_has_shelves/1.xml
  def destroy
    @user_has_shelf = UserHasShelf.find(params[:id])
    @user_has_shelf.destroy

    respond_to do |format|
      format.html { redirect_to(user_has_shelves_url) }
      format.xml  { head :ok }
    end
  end
end
