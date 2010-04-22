class ManifestationHasManifestationsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation
  before_filter :prepare_options, :only => [:new, :edit]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /manifestation_has_manifestations
  # GET /manifestation_has_manifestations.xml
  def index
    if @manifestation
      if params[:mode] == 'add'
        @manifestation_has_manifestations = ManifestationHasManifestation.paginate(:all, :page => params[:page])
      else
        @manifestation_has_manifestations = @manifestation.to_manifestations.paginate(:all, :page => params[:page])
      end
    else
      @manifestation_has_manifestations = ManifestationHasManifestation.paginate(:all, :page => params[:page])
    end

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
    @manifestation_has_manifestation.from_manifestation = @manifestation
    @manifestation_has_manifestation.to_manifestation = Manifestation.find(params[:to_manifestation_id]) rescue nil

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
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_has_manifestation'))
        format.html { redirect_to(@manifestation_has_manifestation) }
        format.xml  { render :xml => @manifestation_has_manifestation, :status => :created, :location => @manifestation_has_manifestation }
      else
        prepare_options
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
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.manifestation_has_manifestation'))
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

  private
  def prepare_options
    @manifestation_relationship_types = ManifestationRelationshipType.all
  end
end
