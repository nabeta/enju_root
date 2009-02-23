class ManifestationHasManifestationsController < ApplicationController
  before_filter :has_permission?

  # GET /manifestation_has_manifestations
  # GET /manifestation_has_manifestations.xml
  def index
    @manifestation_has_manifestations = ManifestationHasManifestation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestation_has_manifestations }
    end
  end

  # GET /manifestation_has_manifestations/1
  # GET /manifestation_has_manifestations/1.xml
  def show
    @manifestation_has_manifestation = ManifestationHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @manifestation_has_manifestation }
    end
  end

  # GET /manifestation_has_manifestations/new
  # GET /manifestation_has_manifestations/new.xml
  def new
    @manifestation_has_manifestation = ManifestationHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation_has_manifestation }
    end
  end

  # GET /manifestation_has_manifestations/1/edit
  def edit
    @manifestation_has_manifestation = ManifestationHasManifestation.find(params[:id])
  end

  # POST /manifestation_has_manifestations
  # POST /manifestation_has_manifestations.xml
  def create
    @manifestation_has_manifestation = ManifestationHasManifestation.new(params[:manifestation_has_manifestation])

    respond_to do |format|
      if @manifestation_has_manifestation.save
        flash[:notice] = 'ManifestationHasManifestation was successfully created.'
        format.html { redirect_to(@manifestation_has_manifestation) }
        format.xml  { render :xml => @manifestation_has_manifestation, :status => :created, :location => @manifestation_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_has_manifestations/1
  # PUT /manifestation_has_manifestations/1.xml
  def update
    @manifestation_has_manifestation = ManifestationHasManifestation.find(params[:id])

    respond_to do |format|
      if @manifestation_has_manifestation.update_attributes(params[:manifestation_has_manifestation])
        flash[:notice] = 'ManifestationHasManifestation was successfully updated.'
        format.html { redirect_to(@manifestation_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_has_manifestations/1
  # DELETE /manifestation_has_manifestations/1.xml
  def destroy
    @manifestation_has_manifestation = ManifestationHasManifestation.find(params[:id])
    @manifestation_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end
