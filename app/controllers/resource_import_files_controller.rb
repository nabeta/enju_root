class ResourceImportFilesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /resource_import_files
  # GET /resource_import_files.json
  def index
    @resource_import_files = ResourceImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @resource_import_files }
    end
  end

  # GET /resource_import_files/1
  # GET /resource_import_files/1.json
  def show
    @resource_import_file = ResourceImportFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @resource_import_file }
      format.download  { send_file @resource_import_file.resource_import.path, :filename => @resource_import_file.resource_import_file_name, :type => @resource_import_file.resource_import_content_type, :disposition => 'inline' }
    end
  end

  # GET /resource_import_files/new
  # GET /resource_import_files/new.json
  def new
    @resource_import_file = ResourceImportFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @resource_import_file }
    end
  end

  # GET /resource_import_files/1/edit
  def edit
    @resource_import_file = ResourceImportFile.find(params[:id])
  end

  # POST /resource_import_files
  # POST /resource_import_files.json
  def create
    @resource_import_file = ResourceImportFile.new(params[:resource_import_file])
    @resource_import_file.user = current_user

    respond_to do |format|
      if @resource_import_file.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_import_file'))
        format.html { redirect_to(@resource_import_file) }
        format.json { render :json => @resource_import_file, :status => :created, :location => @resource_import_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  #rescue
  #  flash[:notice] = ('Invalid file.')
  #  redirect_to new_resource_import_file_url
  end

  # PUT /resource_import_files/1
  # PUT /resource_import_files/1.json
  def update
    @resource_import_file = ResourceImportFile.find(params[:id])

    respond_to do |format|
      if @resource_import_file.update_attributes(params[:resource_import_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.resource_import_file'))
        format.html { redirect_to(@resource_import_file) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @resource_import_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_import_files/1
  # DELETE /resource_import_files/1.json
  def destroy
    @resource_import_file = ResourceImportFile.find(params[:id])
    @resource_import_file.destroy

    respond_to do |format|
      format.html { redirect_to(resource_import_files_url) }
      format.json { head :no_content }
    end
  end
end
