class PlacesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /places
  # GET /places.xml
  def index
    if params[:query]
      @query = params[:query]
      flash[:query] = @query
    end

    if @query.blank?
      @places = Place.paginate(:all, :page => params[:page])
    else
      @places = Place.paginate_by_solr(@query, :page => params[:page], :per_page => @per_page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @places }
    end
  end

  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
  def new
    @place = Place.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
  end

  # POST /places
  # POST /places.xml
  def create
    @place = Place.new(params[:place])

    respond_to do |format|
      if @place.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.place'))
        format.html { redirect_to(@place) }
        format.xml  { render :xml => @place, :status => :created, :location => @place }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.place'))
        format.html { redirect_to(@place) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.xml
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to(places_url) }
      format.xml  { head :ok }
    end
  end
end
