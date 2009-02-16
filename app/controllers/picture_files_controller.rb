class PictureFilesController < ApplicationController
  before_filter :login_required
  require_role 'Librarian'
  before_filter :get_manifestation, :only => [:index, :new]
  before_filter :get_patron, :only => [:index, :new, :create]
  before_filter :get_event, :only => [:index, :new, :create]
  before_filter :get_shelf, :only => [:index, :new, :create]

  # GET /picture_files
  # GET /picture_files.xml
  def index
    case
    when @manifestation
      @picture_files = @manifestation.picture_files.paginate(:page => params[:page], :order => ['picture_files.id'])
    when @event
      @picture_files = @event.picture_files.paginate(:page => params[:page], :order => ['picture_files.id'])
    when @shelf
      @picture_files = @shelf.picture_files.paginate(:page => params[:page], :order => ['picture_files.id'])
    else
      @picture_files = PictureFile.paginate(:all, :page => params[:page], :order => :id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @picture_files }
    end
  end

  # GET /picture_files/1
  # GET /picture_files/1.xml
  def show
    @picture_file = PictureFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @picture_file }
      format.jpg  { send_data @picture_file.db_file.data, :filename => @picture_file.filename, :type => 'image/jpeg', :disposition => 'inline' }
      format.gif  { send_data @picture_file.db_file.data, :filename => @picture_file.filename, :type => 'image/gif', :disposition => 'inline' }
      format.png  { send_data @picture_file.db_file.data, :filename => @picture_file.filename, :type => 'image/png', :disposition => 'inline' }
    end
  end

  # GET /picture_files/new
  # GET /picture_files/new.xml
  def new
    #raise unless @event or @manifestation or @shelf or @patron
    @picture_file = PictureFile.new
    case
    when @patron
      @picture_file.picture_attachable = @patron
    when @event
      @picture_file.picture_attachable = @event
    when @shelf
      @picture_file.picture_attachable = @shelf 
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @picture_file }
    end
  #rescue
  #  access_denied
  end

  # GET /picture_files/1/edit
  def edit
    @picture_file = PictureFile.find(params[:id])
  end

  # POST /picture_files
  # POST /picture_files.xml
  def create
    @picture_file = PictureFile.new(params[:picture_file])
    @picture_file.picture_attachable_id = params[:picture_file][:picture_attachable_id]
    @picture_file.picture_attachable_type = params[:picture_file][:picture_attachable_type]

    respond_to do |format|
      if @picture_file.save
        #@picture_file.sha1_hash = @picture_file.digest(:type => 'sha1')
        #@picture_file.save

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.picture_file'))
        #format.html { redirect_to(@picture_file) }
        format.html { redirect_to(@picture_file) }
        format.xml  { render :xml => @picture_file, :status => :created, :location => @picture_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @picture_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /picture_files/1
  # PUT /picture_files/1.xml
  def update
    @picture_file = PictureFile.find(params[:id])

    respond_to do |format|
      if @picture_file.update_attributes(params[:picture_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.picture_file'))
        format.html { redirect_to(@picture_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @picture_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /picture_files/1
  # DELETE /picture_files/1.xml
  def destroy
    @picture_file = PictureFile.find(params[:id])
    @picture_file.destroy

    respond_to do |format|
      format.html { redirect_to(picture_files_url) }
      format.xml  { head :ok }
    end
  end

end
