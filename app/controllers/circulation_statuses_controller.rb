class CirculationStatusesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]

  # GET /circulation_statuses
  # GET /circulation_statuses.xml
  def index
    @circulation_statuses = CirculationStatus.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @circulation_statuses }
    end
  end

  # GET /circulation_statuses/1
  # GET /circulation_statuses/1.xml
  def show
    @circulation_status = CirculationStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @circulation_status }
    end
  end

  # GET /circulation_statuses/new
  # GET /circulation_statuses/new.xml
  def new
    @circulation_status = CirculationStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @circulation_status }
    end
  end

  # GET /circulation_statuses/1/edit
  def edit
    @circulation_status = CirculationStatus.find(params[:id])
  end

  # POST /circulation_statuses
  # POST /circulation_statuses.xml
  def create
    @circulation_status = CirculationStatus.new(params[:circulation_status])

    respond_to do |format|
      if @circulation_status.save
        flash[:notice] = ('CirculationStatus was successfully created.')
        format.html { redirect_to(@circulation_status) }
        format.xml  { render :xml => @circulation_status, :status => :created, :location => @circulation_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @circulation_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /circulation_statuses/1
  # PUT /circulation_statuses/1.xml
  def update
    @circulation_status = CirculationStatus.find(params[:id])

    if @shelf and params[:position]
      @shelf.insert_at(params[:position])
      redirect_to shelves_url
      return
    end

    respond_to do |format|
      if @circulation_status.update_attributes(params[:circulation_status])
        flash[:notice] = ('CirculationStatus was successfully updated.')
        format.html { redirect_to(@circulation_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @circulation_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /circulation_statuses/1
  # DELETE /circulation_statuses/1.xml
  def destroy
    @circulation_status = CirculationStatus.find(params[:id])
    @circulation_status.destroy

    respond_to do |format|
      format.html { redirect_to(circulation_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
