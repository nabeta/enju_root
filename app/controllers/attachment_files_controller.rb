class AttachmentFilesController < ApplicationController
  before_filter :login_required
  before_filter :get_manifestation, :only => [:index, :new]
  before_filter :get_patron, :only => [:index, :new]
  before_filter :get_event, :only => [:index, :new]
  before_filter :get_shelf, :only => [:index, :new]
  require_role 'Librarian'

  # GET /attachment_files
  # GET /attachment_files.xml
  def index
    case
    when @manifestation
      @attachment_files = @manifestation.attachment_files.paginate(:page => params[:page], :per_page => @per_page, :order => ['attachment_files.id'])
    when @event
      @attachment_files = @event.attachment_files.paginate(:page => params[:page], :per_page => @per_page, :order => ['attachment_files.id'])
    when @shelf
      @attachment_files = @shelf.attachment_files.paginate(:page => params[:page], :per_page => @per_page, :order => ['attachment_files.id'])
    else
      @attachment_files = AttachmentFile.paginate(:all, :page => params[:page], :per_page => @per_page, :order => :id)
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
    #raise unless @event or @manifestation or @shelf or @patron
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
    @attachment_file.attachable_id = params[:attachment_file][:attachable_id]
    @attachment_file.attachable_type = params[:attachment_file][:attachable_type]

    respond_to do |format|
      if @attachment_file.save
        unless @attachment_file.attachable
          @attachment_file.create_resource(params[:attachment_file][:title])
        end
        @attachment_file.extract_text
        #@attachment_file.file_hash = @attachment_file.digest(:type => 'sha1')

        case @attachment_file.attachable_type
        when 'Work'
        when 'Expression'
        when 'Manifestation'
        when 'Item'
        when 'Patron'
        end
        @attachment_file.save

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
    @attachment_file.extract_text

    respond_to do |format|
      if @attachment_file.update_attributes(params[:attachment_file])
        @attachment_file.extract_text
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

    respond_to do |format|
      format.html { redirect_to(attachment_files_url) }
      format.xml  { head :ok }
    end
  end

end
