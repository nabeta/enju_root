class PatronRelationshipTypesController < ApplicationController
  before_filter :has_permission?

  # GET /patron_relationship_types
  # GET /patron_relationship_types.xml
  def index
    @patron_relationship_types = PatronRelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patron_relationship_types }
    end
  end

  # GET /patron_relationship_types/1
  # GET /patron_relationship_types/1.xml
  def show
    @patron_relationship_type = PatronRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patron_relationship_type }
    end
  end

  # GET /patron_relationship_types/new
  # GET /patron_relationship_types/new.xml
  def new
    @patron_relationship_type = PatronRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron_relationship_type }
    end
  end

  # GET /patron_relationship_types/1/edit
  def edit
    @patron_relationship_type = PatronRelationshipType.find(params[:id])
  end

  # POST /patron_relationship_types
  # POST /patron_relationship_types.xml
  def create
    @patron_relationship_type = PatronRelationshipType.new(params[:patron_relationship_type])

    respond_to do |format|
      if @patron_relationship_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_relationship_type'))
        format.html { redirect_to(@patron_relationship_type) }
        format.xml  { render :xml => @patron_relationship_type, :status => :created, :location => @patron_relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_relationship_types/1
  # PUT /patron_relationship_types/1.xml
  def update
    @patron_relationship_type = PatronRelationshipType.find(params[:id])

    respond_to do |format|
      if @patron_relationship_type.update_attributes(params[:patron_relationship_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_relationship_type'))
        format.html { redirect_to(@patron_relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_relationship_types/1
  # DELETE /patron_relationship_types/1.xml
  def destroy
    @patron_relationship_type = PatronRelationshipType.find(params[:id])
    @patron_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(patron_relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
