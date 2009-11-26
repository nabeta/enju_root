class PatronHasPatronsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_patron
  before_filter :prepare_options, :only => [:new, :edit]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /patron_has_patrons
  # GET /patron_has_patrons.xml
  def index
    if @patron
      if params[:mode] == 'add'
        @patron_has_patrons = PatronHasPatron.paginate(:all, :page => params[:page])
      else
        @patron_has_patrons = @patron.to_patrons.paginate(:all, :page => params[:page])
      end
    else
      @patron_has_patrons = PatronHasPatron.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patron_has_patrons }
    end
  end

  # GET /patron_has_patrons/1
  # GET /patron_has_patrons/1.xml
  def show
    @patron_has_patron = PatronHasPatron.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patron_has_patron }
    end
  end

  # GET /patron_has_patrons/new
  # GET /patron_has_patrons/new.xml
  def new
    @patron_has_patron = PatronHasPatron.new
    @patron_has_patron.from_patron = @patron
    @patron_has_patron.to_patron = Patron.find(params[:to_patron_id]) rescue nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron_has_patron }
    end
  end

  # GET /patron_has_patrons/1/edit
  def edit
    @patron_has_patron = PatronHasPatron.find(params[:id])
  end

  # POST /patron_has_patrons
  # POST /patron_has_patrons.xml
  def create
    @patron_has_patron = PatronHasPatron.new(params[:patron_has_patron])

    respond_to do |format|
      if @patron_has_patron.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_has_patron'))
        format.html { redirect_to(@patron_has_patron) }
        format.xml  { render :xml => @patron_has_patron, :status => :created, :location => @patron_has_patron }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron_has_patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_has_patrons/1
  # PUT /patron_has_patrons/1.xml
  def update
    @patron_has_patron = PatronHasPatron.find(params[:id])

    respond_to do |format|
      if @patron_has_patron.update_attributes(params[:patron_has_patron])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_has_patron'))
        format.html { redirect_to(@patron_has_patron) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron_has_patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_has_patrons/1
  # DELETE /patron_has_patrons/1.xml
  def destroy
    @patron_has_patron = PatronHasPatron.find(params[:id])
    @patron_has_patron.destroy

    respond_to do |format|
      format.html { redirect_to(patron_has_patrons_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @patron_relationship_types = PatronRelationshipType.all
  end
end
