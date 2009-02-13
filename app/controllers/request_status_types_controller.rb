class RequestStatusTypesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  require_role 'Administrator', :except => [:index, :show]
  require_role 'Librarian', :only => [:index, :show]

  # GET /request_status_types
  # GET /request_status_types.xml
  def index
    @request_status_types = RequestStatusType.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @request_status_types }
    end
  end

  # GET /request_status_types/1
  # GET /request_status_types/1.xml
  def show
    @request_status_type = RequestStatusType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request_status_type }
    end
  end

  # GET /request_status_types/new
  # GET /request_status_types/new.xml
  def new
    @request_status_type = RequestStatusType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request_status_type }
    end
  end

  # GET /request_status_types/1/edit
  def edit
    @request_status_type = RequestStatusType.find(params[:id])
  end

  # POST /request_status_types
  # POST /request_status_types.xml
  def create
    @request_status_type = RequestStatusType.new(params[:request_status_type])

    respond_to do |format|
      if @request_status_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.request_status_type'))
        format.html { redirect_to(@request_status_type) }
        format.xml  { render :xml => @request_status_type, :status => :created, :location => @request_status_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request_status_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /request_status_types/1
  # PUT /request_status_types/1.xml
  def update
    @request_status_type = RequestStatusType.find(params[:id])

    respond_to do |format|
      if @request_status_type.update_attributes(params[:request_status_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.request_status_type'))
        format.html { redirect_to(@request_status_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request_status_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /request_status_types/1
  # DELETE /request_status_types/1.xml
  def destroy
    @request_status_type = RequestStatusType.find(params[:id])
    @request_status_type.destroy

    respond_to do |format|
      format.html { redirect_to(request_status_types_url) }
      format.xml  { head :ok }
    end
  end
end
