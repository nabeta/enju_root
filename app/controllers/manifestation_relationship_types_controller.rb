class ManifestationRelationshipTypesController < ApplicationController
  # GET /manifestation_relationship_types
  # GET /manifestation_relationship_types.xml
  def index
    @manifestation_relationship_types = ManifestationRelationshipType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestation_relationship_types }
    end
  end

  # GET /manifestation_relationship_types/1
  # GET /manifestation_relationship_types/1.xml
  def show
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @manifestation_relationship_type }
    end
  end

  # GET /manifestation_relationship_types/new
  # GET /manifestation_relationship_types/new.xml
  def new
    @manifestation_relationship_type = ManifestationRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation_relationship_type }
    end
  end

  # GET /manifestation_relationship_types/1/edit
  def edit
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])
  end

  # POST /manifestation_relationship_types
  # POST /manifestation_relationship_types.xml
  def create
    @manifestation_relationship_type = ManifestationRelationshipType.new(params[:manifestation_relationship_type])

    respond_to do |format|
      if @manifestation_relationship_type.save
        flash[:notice] = 'ManifestationRelationshipType was successfully created.'
        format.html { redirect_to(@manifestation_relationship_type) }
        format.xml  { render :xml => @manifestation_relationship_type, :status => :created, :location => @manifestation_relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_relationship_types/1
  # PUT /manifestation_relationship_types/1.xml
  def update
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])

    respond_to do |format|
      if @manifestation_relationship_type.update_attributes(params[:manifestation_relationship_type])
        flash[:notice] = 'ManifestationRelationshipType was successfully updated.'
        format.html { redirect_to(@manifestation_relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_relationship_types/1
  # DELETE /manifestation_relationship_types/1.xml
  def destroy
    @manifestation_relationship_type = ManifestationRelationshipType.find(params[:id])
    @manifestation_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
