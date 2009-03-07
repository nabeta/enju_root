class ImportedResourceFilesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?

  # GET /imported_resource_files
  # GET /imported_resource_files.xml
  def index
    @imported_resource_files = ImportedResourceFile.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @imported_resource_files }
    end
  end

  # GET /imported_resource_files/1
  # GET /imported_resource_files/1.xml
  def show
    @imported_resource_file = ImportedResourceFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @imported_resource_file }
    end
  end

  # GET /imported_resource_files/new
  # GET /imported_resource_files/new.xml
  def new
    @imported_resource_file = ImportedResourceFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @imported_resource_file }
    end
  end

  # GET /imported_resource_files/1/edit
  def edit
    @imported_resource_file = ImportedResourceFile.find(params[:id])
  end

  # POST /imported_resource_files
  # POST /imported_resource_files.xml
  def create
    @imported_resource_file = ImportedResourceFile.new(params[:imported_resource_file])
    @imported_resource_file.user = current_user
    #@imporetd_resource_file.file_hash = Digest::SHA1.hexdigest(params[:imported_resource_file][:uploaded_data])

    respond_to do |format|
      if @imported_resource_file.save
        # TODO: 他の形式
        #num = @imported_resource_file.import_csv
        #flash[:notice] = n('%{num} resource is imported.', '%{num} resources are imported', num) % {:num => num}
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.imporeted_resource_file'))
        flash[:notice] += t('imported_resource_file.will_be_imported', :minute => 60) # TODO: インポートまでの時間表記

        #@imported_resource_file.import
        format.html { redirect_to(@imported_resource_file) }
        format.xml  { render :xml => @imported_resource_file, :status => :created, :location => @imported_resource_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @imported_resource_file.errors, :status => :unprocessable_entity }
      end
    end
  #rescue
  #  flash[:notice] = ('Invalid file.')
  #  redirect_to new_imported_resource_file_url
  end

  # PUT /imported_resource_files/1
  # PUT /imported_resource_files/1.xml
  def update
    @imported_resource_file = ImportedResourceFile.find(params[:id])

    respond_to do |format|
      if @imported_resource_file.update_attributes(params[:imported_resource_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.imported_resource_file'))
        format.html { redirect_to(@imported_resource_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @imported_resource_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /imported_resource_files/1
  # DELETE /imported_resource_files/1.xml
  def destroy
    @imported_resource_file = ImportedResourceFile.find(params[:id])
    @imported_resource_file.destroy

    respond_to do |format|
      format.html { redirect_to(imported_resource_files_url) }
      format.xml  { head :ok }
    end
  end
end
