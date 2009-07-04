class ShelfHasManifestationsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_shelf

  # GET /shelf_has_manifestations
  # GET /shelf_has_manifestations.xml
  def index
    @shelf_has_manifestations = ShelfHasManifestation.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shelf_has_manifestations }
    end
  end

  # GET /shelf_has_manifestations/1
  # GET /shelf_has_manifestations/1.xml
  def show
    @shelf_has_manifestation = ShelfHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shelf_has_manifestation }
    end
  end

  # GET /shelf_has_manifestations/new
  # GET /shelf_has_manifestations/new.xml
  def new
    @shelf_has_manifestation = ShelfHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shelf_has_manifestation }
    end
  end

  # GET /shelf_has_manifestations/1/edit
  def edit
    @shelf_has_manifestation = ShelfHasManifestation.find(params[:id])
  end

  # POST /shelf_has_manifestations
  # POST /shelf_has_manifestations.xml
  def create
    @shelf_has_manifestation = ShelfHasManifestation.new(params[:shelf_has_manifestation])

    respond_to do |format|
      if @shelf_has_manifestation.save
        flash[:notice] = 'ShelfHasManifestation was successfully created.'
        format.html { redirect_to(@shelf_has_manifestation) }
        format.xml  { render :xml => @shelf_has_manifestation, :status => :created, :location => @shelf_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shelf_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shelf_has_manifestations/1
  # PUT /shelf_has_manifestations/1.xml
  def update
    @shelf_has_manifestation = ShelfHasManifestation.find(params[:id])

    respond_to do |format|
      if @shelf_has_manifestation.update_attributes(params[:shelf_has_manifestation])
        flash[:notice] = 'ShelfHasManifestation was successfully updated.'
        format.html { redirect_to(@shelf_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shelf_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shelf_has_manifestations/1
  # DELETE /shelf_has_manifestations/1.xml
  def destroy
    @shelf_has_manifestation = ShelfHasManifestation.find(params[:id])
    @shelf_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(shelf_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end
