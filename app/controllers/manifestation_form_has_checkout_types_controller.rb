class ManifestationFormHasCheckoutTypesController < ApplicationController
  before_filter :has_permission?
  before_filter :get_checkout_type
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /manifestation_form_has_checkout_types
  # GET /manifestation_form_has_checkout_types.xml
  def index
    @manifestation_form_has_checkout_types = ManifestationFormHasCheckoutType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestation_form_has_checkout_types }
    end
  end

  # GET /manifestation_form_has_checkout_types/1
  # GET /manifestation_form_has_checkout_types/1.xml
  def show
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @manifestation_form_has_checkout_type }
    end
  end

  # GET /manifestation_form_has_checkout_types/new
  # GET /manifestation_form_has_checkout_types/new.xml
  def new
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.new
    @manifestation_form_has_checkout_type.manifestation_form = @manifestation_form
    @manifestation_form_has_checkout_type.checkout_type = @checkout_type

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation_form_has_checkout_type }
    end
  end

  # GET /manifestation_form_has_checkout_types/1/edit
  def edit
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.find(params[:id])
  end

  # POST /manifestation_form_has_checkout_types
  # POST /manifestation_form_has_checkout_types.xml
  def create
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.new(params[:manifestation_form_has_checkout_type])

    respond_to do |format|
      if @manifestation_form_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_form_has_checkout_type'))
        format.html { redirect_to(@manifestation_form_has_checkout_type) }
        format.xml  { render :xml => @manifestation_form_has_checkout_type, :status => :created, :location => @manifestation_form_has_checkout_type }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation_form_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_form_has_checkout_types/1
  # PUT /manifestation_form_has_checkout_types/1.xml
  def update
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.find(params[:id])

    respond_to do |format|
      if @manifestation_form_has_checkout_type.update_attributes(params[:manifestation_form_has_checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.manifestation_form_has_checkout_type'))
        format.html { redirect_to(@manifestation_form_has_checkout_type) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation_form_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_form_has_checkout_types/1
  # DELETE /manifestation_form_has_checkout_types/1.xml
  def destroy
    @manifestation_form_has_checkout_type = ManifestationFormHasCheckoutType.find(params[:id])
    @manifestation_form_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_form_has_checkout_types_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @checkout_types = CheckoutType.find(:all, :order => :position)
    @manifestation_forms = ManifestationForm.find(:all, :order => :position)
  end
end
