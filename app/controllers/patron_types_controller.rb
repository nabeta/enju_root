class PatronTypesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?

  # GET /patron_types
  # GET /patron_types.xml
  def index
    @patron_types = PatronType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patron_types }
    end
  end

  # GET /patron_types/1
  # GET /patron_types/1.xml
  def show
    @patron_type = PatronType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patron_type }
    end
  end

  # GET /patron_types/new
  # GET /patron_types/new.xml
  def new
    @patron_type = PatronType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron_type }
    end
  end

  # GET /patron_types/1/edit
  def edit
    @patron_type = PatronType.find(params[:id])
  end

  # POST /patron_types
  # POST /patron_types.xml
  def create
    @patron_type = PatronType.new(params[:patron_type])

    respond_to do |format|
      if @patron_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_type'))
        format.html { redirect_to(@patron_type) }
        format.xml  { render :xml => @patron_type, :status => :created, :location => @patron_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_types/1
  # PUT /patron_types/1.xml
  def update
    @patron_type = PatronType.find(params[:id])

    respond_to do |format|
      if @patron_type.update_attributes(params[:patron_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_type'))
        format.html { redirect_to(@patron_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_types/1
  # DELETE /patron_types/1.xml
  def destroy
    @patron_type = PatronType.find(params[:id])
    @patron_type.destroy

    respond_to do |format|
      format.html { redirect_to(patron_types_url) }
      format.xml  { head :ok }
    end
  end
end
