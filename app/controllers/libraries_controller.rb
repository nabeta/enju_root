class LibrariesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /libraries
  # GET /libraries.xml
  def index
    @libraries = Library.paginate(:all, :page => params[:page], :order => 'position')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @libraries }
    end
  end

  # GET /libraries/1
  # GET /libraries/1.xml
  def show
    @library = Library.find(:first, :conditions => {:short_name => params[:id]}, :include => :shelves)
    raise ActiveRecord::RecordNotFound if @library.nil?
    if params[:date]
      @date = Time.parse(params[:date]) rescue Time.zone.now
      render :partial => 'calendar'
      return
    else
      @date = Time.zone.now
    end

    begin
      if @library.lat and @library.lng
        coord = [@library.lat, @library.lng]
        @map = GMap.new("map_div")
        @map.control_init(:large_map => true,:map_type => true)
        @map.center_zoom_init(coord, 15)
        @map.overlay_init(GMarker.new(coord, :title => @library.name))
      end
    rescue
      nil
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @library }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /libraries/new
  def new
    #@patron = Patron.find(params[:patron_id]) rescue nil
    #unless @patron
    #  flash[:notice] = ('Specify patron id.')
    #  redirect_to patrons_url
    #  return
    #end
    @library = Library.new
    @library_groups = LibraryGroup.find(:all, :order => 'id')
  end

  # GET /libraries/1;edit
  def edit
    @library = Library.find(:first, :conditions => {:short_name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.nil?
    @library_groups = LibraryGroup.find(:all, :order => 'id')
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /libraries
  # POST /libraries.xml
  def create
    #patron = Patron.create(:name => params[:library][:name], :patron_type => 'CorporateBody')
    @library = Library.new(params[:library])
    @patron = Patron.create(:full_name => @library.name)
    @library.patron = @patron

    respond_to do |format|
      if @library.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.library'))
        format.html { redirect_to library_url(@library.short_name) }
        format.xml  { render :xml => @library, :status => :created, :location => library_url(@library.short_name) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /libraries/1
  # PUT /libraries/1.xml
  def update
    @library = Library.find(:first, :conditions => {:short_name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.nil?

    if @library and params[:position]
      @library.insert_at(params[:position])
      redirect_to libraries_url
      return
    end

    respond_to do |format|
      if @library.update_attributes(params[:library])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.library'))
        format.html { redirect_to library_url(@library.short_name) }
        format.xml  { head :ok }
      else
        @library.short_name = @library.short_name_was
        format.html { render :action => "edit" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.xml
  def destroy
    @library = Library.find(:first, :conditions => {:short_name => params[:id]})
    raise ActiveRecord::RecordNotFound if @library.nil?
    raise if @library.id == 1

    @library.destroy

    respond_to do |format|
      format.html { redirect_to libraries_url }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  rescue
    access_denied
  end
end
