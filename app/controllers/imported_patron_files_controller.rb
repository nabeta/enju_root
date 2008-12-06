class ImportedPatronFilesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  require_role 'Librarian'

  # GET /imported_patron_files
  # GET /imported_patron_files.xml
  def index
    @imported_patron_files = ImportedPatronFile.paginate(:all, :page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @imported_patron_files }
    end
  end

  # GET /imported_patron_files/1
  # GET /imported_patron_files/1.xml
  def show
    @imported_patron_file = ImportedPatronFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @imported_patron_file }
    end
  end

  # GET /imported_patron_files/new
  # GET /imported_patron_files/new.xml
  def new
    @imported_patron_file = ImportedPatronFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @imported_patron_file }
    end
  end

  # GET /imported_patron_files/1/edit
  def edit
    @imported_patron_file = ImportedPatronFile.find(params[:id])
  end

  # POST /imported_patron_files
  # POST /imported_patron_files.xml
  def create
    @imported_patron_file = ImportedPatronFile.new(params[:imported_patron_file])
    @imported_patron_file.user = current_user

    respond_to do |format|
      if @imported_patron_file.save
        #num = @imported_patron_file.import_patrons
        #flash[:notice] = n('%{num} patron is imported.', '%{num} patrons are imported.', num) % {:num => num[:success]}
        #flash[:notice] += n('%{num} patron is not imported.', '%{num} patrons are not imported.', num) % {:num => num[:failure]} if num[:failure] > 0
        #flash[:notice] = n('%{num} user is activated.', '%{num} users are activated.', num) % {:num => num[:activated]} if num[:activated] > 0
        #flash[:notice] = ('ImportedPatronFile was successfully created.')
        flash[:notice] = ('ImportedPatronFile was successfully created. Patrons will be imported in a hour.')
        @imported_patron_file.import
        format.html { redirect_to(@imported_patron_file) }
        format.xml  { render :xml => @imported_patron_file, :status => :created, :location => @imported_patron_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @imported_patron_file.errors, :status => :unprocessable_entity }
      end
    end
  rescue
    flash[:notice] = ('Invalid file.')
    redirect_to new_imported_resource_file_url
  end

  # PUT /imported_patron_files/1
  # PUT /imported_patron_files/1.xml
  def update
    @imported_patron_file = ImportedPatronFile.find(params[:id])

    respond_to do |format|
      if @imported_patron_file.update_attributes(params[:imported_patron_file])
        flash[:notice] = ('ImportedPatronFile was successfully updated.')
        format.html { redirect_to(@imported_patron_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @imported_patron_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /imported_patron_files/1
  # DELETE /imported_patron_files/1.xml
  def destroy
    @imported_patron_file = ImportedPatronFile.find(params[:id])
    @imported_patron_file.destroy

    respond_to do |format|
      format.html { redirect_to(imported_patron_files_url) }
      format.xml  { head :ok }
    end
  end
end
