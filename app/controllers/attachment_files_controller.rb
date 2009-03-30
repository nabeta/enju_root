class AttachmentFilesController < ApplicationController
  before_filter :has_permission?
  before_filter :get_manifestation, :only => [:index, :new]

  # GET /attachment_files
  # GET /attachment_files.xml
  def index
    if @manifestation
      @attachment_files = @manifestation.attachment_files.paginate(:page => params[:page])
    else
      @attachment_files = AttachmentFile.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attachment_files }
    end
  end

  # GET /attachment_files/1
  # GET /attachment_files/1.xml
  def show
    @attachment_file = AttachmentFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attachment_file }
      format.download { send_data @attachment_file.db_file.data, :filename => @attachment_file.filename, :type => 'application/octet-stream' }
    end
  end

  # GET /attachment_files/new
  # GET /attachment_files/new.xml
  def new
    @attachment_file = AttachmentFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment_file }
    end
  #rescue
  #  access_denied
  end

  # GET /attachment_files/1/edit
  def edit
    @attachment_file = AttachmentFile.find(params[:id])
  end

  # POST /attachment_files
  # POST /attachment_files.xml
  def create
    @attachment_file = AttachmentFile.new(params[:attachment_file])
    @attachment_file.post_to_scribd = params[:attachment_file][:post_to_scribd]
    @attachment_file.post_to_twitter = params[:attachment_file][:post_to_twitter]
    title = params[:attachment_file][:title]
    @attachment_file.title = title

    respond_to do |format|
      if @attachment_file.save
        AttachmentFile.find_by_sql(['UPDATE attachment_files SET file_hash = ? WHERE id = ?', @attachment_file.digest, @attachment_file.id])

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.attachment_file'))
        format.html { redirect_to(@attachment_file) }
        format.xml  { render :xml => @attachment_file, :status => :created, :location => @attachment_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /attachment_files/1
  # PUT /attachment_files/1.xml
  def update
    @attachment_file = AttachmentFile.find(params[:id])
    @attachment_file.manifestation_id = params[:attachment_file][:manifestation_id]

    respond_to do |format|
      if @attachment_file.update_attributes(params[:attachment_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.attachment_file'))
        format.html { redirect_to(@attachment_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attachment_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /attachment_files/1
  # DELETE /attachment_files/1.xml
  def destroy
    @attachment_file = AttachmentFile.find(params[:id])
    @attachment_file.destroy
    #rescue ScribdFu::ScribdFuError

    respond_to do |format|
      format.html { redirect_to(attachment_files_url) }
      format.xml  { head :ok }
    end
  end

end
