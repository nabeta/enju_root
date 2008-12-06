class ImportedObjectsController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'

  # GET /imported_objects
  # GET /imported_objects.xml
  def index
    @imported_objects = ImportedObject.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @imported_objects }
    end
  end

  # GET /imported_objects/1
  # GET /imported_objects/1.xml
  def show
    @imported_object = ImportedObject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @imported_object }
    end
  end

  # GET /imported_objects/new
  # GET /imported_objects/new.xml
  def new
    @imported_object = ImportedObject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @imported_object }
    end
  end

  # GET /imported_objects/1/edit
  def edit
    @imported_object = ImportedObject.find(params[:id])
  end

  # POST /imported_objects
  # POST /imported_objects.xml
  def create
    @imported_object = ImportedObject.new(params[:imported_object])

    respond_to do |format|
      if @imported_object.save
        flash[:notice] = ('ImportedObject was successfully created.')
        format.html { redirect_to(@imported_object) }
        format.xml  { render :xml => @imported_object, :status => :created, :location => @imported_object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @imported_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /imported_objects/1
  # PUT /imported_objects/1.xml
  def update
    @imported_object = ImportedObject.find(params[:id])

    respond_to do |format|
      if @imported_object.update_attributes(params[:imported_object])
        flash[:notice] = ('ImportedObject was successfully updated.')
        format.html { redirect_to(@imported_object) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @imported_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /imported_objects/1
  # DELETE /imported_objects/1.xml
  def destroy
    @imported_object = ImportedObject.find(params[:id])
    @imported_object.destroy

    respond_to do |format|
      format.html { redirect_to(imported_objects_url) }
      format.xml  { head :ok }
    end
  end
end
