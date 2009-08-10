class ExtentsController < ApplicationController
  before_filter :has_permission?

  # GET /extents
  # GET /extents.xml
  def index
    @extents = Extent.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @extents }
    end
  end

  # GET /extents/1
  # GET /extents/1.xml
  def show
    @extent = Extent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @extent }
    end
  end

  # GET /extents/new
  # GET /extents/new.xml
  def new
    @extent = Extent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @extent }
    end
  end

  # GET /extents/1/edit
  def edit
    @extent = Extent.find(params[:id])
  end

  # POST /extents
  # POST /extents.xml
  def create
    @extent = Extent.new(params[:extent])

    respond_to do |format|
      if @extent.save
        flash[:notice] = 'Extent was successfully created.'
        format.html { redirect_to(@extent) }
        format.xml  { render :xml => @extent, :status => :created, :location => @extent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @extent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /extents/1
  # PUT /extents/1.xml
  def update
    @extent = Extent.find(params[:id])

    respond_to do |format|
      if @extent.update_attributes(params[:extent])
        flash[:notice] = 'Extent was successfully updated.'
        format.html { redirect_to(@extent) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @extent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /extents/1
  # DELETE /extents/1.xml
  def destroy
    @extent = Extent.find(params[:id])
    @extent.destroy

    respond_to do |format|
      format.html { redirect_to(extents_url) }
      format.xml  { head :ok }
    end
  end
end
