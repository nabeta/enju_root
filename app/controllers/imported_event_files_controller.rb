class ImportedEventFilesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  require_role 'Librarian'

  # GET /imported_event_files
  # GET /imported_event_files.xml
  def index
    @imported_event_files = ImportedEventFile.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @imported_event_files }
    end
  end

  # GET /imported_event_files/1
  # GET /imported_event_files/1.xml
  def show
    @imported_event_file = ImportedEventFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @imported_event_file }
    end
  end

  # GET /imported_event_files/new
  # GET /imported_event_files/new.xml
  def new
    @imported_event_file = ImportedEventFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @imported_event_file }
    end
  end

  # GET /imported_event_files/1/edit
  def edit
    @imported_event_file = ImportedEventFile.find(params[:id])
  end

  # POST /imported_event_files
  # POST /imported_event_files.xml
  def create
    @imported_event_file = ImportedEventFile.new(params[:imported_event_file])
    @imported_event_file.user = current_user

    respond_to do |format|
      if @imported_event_file.save
        num = @imported_event_file.import_events
        #flash[:notice] = n('%{num} event is imported.', '%{num} events are imported.', num) % {:num => num[:success]}
        #flash[:notice] += n('%{num} event is imported.', '%{num} events are imported.', num) % {:num => num[:failure]} if num[:failure] > 0
        flash[:notice] = ('ImportedEventFile was successfully created. Events will be imported in a hour.')
        format.html { redirect_to(@imported_event_file) }
        format.xml  { render :xml => @imported_event_file, :status => :created, :location => @imported_event_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @imported_event_file.errors, :status => :unprocessable_entity }
      end
    end
  rescue
    flash[:notice] = ('Invalid file.')
    redirect_to new_imported_event_file_url
  end

  # PUT /imported_event_files/1
  # PUT /imported_event_files/1.xml
  def update
    @imported_event_file = ImportedEventFile.find(params[:id])

    respond_to do |format|
      if @imported_event_file.update_attributes(params[:imported_event_file])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.imported_event_file'))
        format.html { redirect_to(@imported_event_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @imported_event_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /imported_event_files/1
  # DELETE /imported_event_files/1.xml
  def destroy
    @imported_event_file = ImportedEventFile.find(params[:id])
    @imported_event_file.destroy

    respond_to do |format|
      format.html { redirect_to(imported_event_files_url) }
      format.xml  { head :ok }
    end
  end
end
