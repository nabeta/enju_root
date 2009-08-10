class CarrierTypesController < ApplicationController
  before_filter :has_permission?

  # GET /carrier_types
  # GET /carrier_types.xml
  def index
    @carrier_types = CarrierType.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @carrier_types.to_xml }
    end
  end

  # GET /carrier_types/1
  # GET /carrier_types/1.xml
  def show
    @carrier_type = CarrierType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @carrier_type.to_xml }
    end
  end

  # GET /carrier_types/new
  def new
    @carrier_type = CarrierType.new
  end

  # GET /carrier_types/1;edit
  def edit
    @carrier_type = CarrierType.find(params[:id])
  end

  # POST /carrier_types
  # POST /carrier_types.xml
  def create
    @carrier_type = CarrierType.new(params[:carrier_type])

    respond_to do |format|
      if @carrier_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.carrier_type'))
        format.html { redirect_to(@carrier_type) }
        format.xml  { render :xml => @carrier_type, :status => :created, :location => @carrier_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @carrier_type.errors.to_xml }
      end
    end
  end

  # PUT /carrier_types/1
  # PUT /carrier_types/1.xml
  def update
    @carrier_type = CarrierType.find(params[:id])

    respond_to do |format|
      if @carrier_type.update_attributes(params[:carrier_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.carrier_type'))
        format.html { redirect_to carrier_type_url(@carrier_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @carrier_type.errors.to_xml }
      end
    end
  end

  # DELETE /carrier_types/1
  # DELETE /carrier_types/1.xml
  def destroy
    @carrier_type = CarrierType.find(params[:id])
    @carrier_type.destroy

    respond_to do |format|
      format.html { redirect_to carrier_types_url }
      format.xml  { head :ok }
    end
  end
end
