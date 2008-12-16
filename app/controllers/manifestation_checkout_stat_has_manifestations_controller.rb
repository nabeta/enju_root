class ManifestationCheckoutStatHasManifestationsController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'

  # GET /manifestation_checkout_stat_has_manifestations
  # GET /manifestation_checkout_stat_has_manifestations.xml
  def index
    @manifestation_checkout_stat_has_manifestations = ManifestationCheckoutStatHasManifestation.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestation_checkout_stat_has_manifestations }
    end
  end

  # GET /manifestation_checkout_stat_has_manifestations/1
  # GET /manifestation_checkout_stat_has_manifestations/1.xml
  def show
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @manifestation_checkout_stat_has_manifestation }
    end
  end

  # GET /manifestation_checkout_stat_has_manifestations/new
  # GET /manifestation_checkout_stat_has_manifestations/new.xml
  def new
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation_checkout_stat_has_manifestation }
    end
  end

  # GET /manifestation_checkout_stat_has_manifestations/1/edit
  def edit
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.find(params[:id])
  end

  # POST /manifestation_checkout_stat_has_manifestations
  # POST /manifestation_checkout_stat_has_manifestations.xml
  def create
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.new(params[:manifestation_checkout_stat_has_manifestation])

    respond_to do |format|
      if @manifestation_checkout_stat_has_manifestation.save
        flash[:notice] = 'ManifestationCheckoutStatHasManifestation was successfully created.'
        format.html { redirect_to(@manifestation_checkout_stat_has_manifestation) }
        format.xml  { render :xml => @manifestation_checkout_stat_has_manifestation, :status => :created, :location => @manifestation_checkout_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation_checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_checkout_stat_has_manifestations/1
  # PUT /manifestation_checkout_stat_has_manifestations/1.xml
  def update
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.find(params[:id])

    respond_to do |format|
      if @manifestation_checkout_stat_has_manifestation.update_attributes(params[:manifestation_checkout_stat_has_manifestation])
        flash[:notice] = 'ManifestationCheckoutStatHasManifestation was successfully updated.'
        format.html { redirect_to(@manifestation_checkout_stat_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation_checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_checkout_stat_has_manifestations/1
  # DELETE /manifestation_checkout_stat_has_manifestations/1.xml
  def destroy
    @manifestation_checkout_stat_has_manifestation = ManifestationCheckoutStatHasManifestation.find(params[:id])
    @manifestation_checkout_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_checkout_stat_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end
