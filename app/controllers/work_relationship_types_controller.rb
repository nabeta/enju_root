class WorkRelationshipTypesController < ApplicationController
  load_and_authorize_resource

  # GET /work_relationship_types
  # GET /work_relationship_types.xml
  def index
    @work_relationship_types = WorkRelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_relationship_types }
    end
  end

  # GET /work_relationship_types/1
  # GET /work_relationship_types/1.xml
  def show
    @work_relationship_type = WorkRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_relationship_type }
    end
  end

  # GET /work_relationship_types/new
  # GET /work_relationship_types/new.xml
  def new
    @work_relationship_type = WorkRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_relationship_type }
    end
  end

  # GET /work_relationship_types/1/edit
  def edit
    @work_relationship_type = WorkRelationshipType.find(params[:id])
  end

  # POST /work_relationship_types
  # POST /work_relationship_types.xml
  def create
    @work_relationship_type = WorkRelationshipType.new(params[:work_relationship_type])

    respond_to do |format|
      if @work_relationship_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_relationship_type'))
        format.html { redirect_to(@work_relationship_type) }
        format.xml  { render :xml => @work_relationship_type, :status => :created, :location => @work_relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_relationship_types/1
  # PUT /work_relationship_types/1.xml
  def update
    @work_relationship_type = WorkRelationshipType.find(params[:id])

    if @work_relationship_type and params[:position]
      @work_relationship_type.insert_at(params[:position])
      redirect_to work_relationship_types_url
      return
    end

    respond_to do |format|
      if @work_relationship_type.update_attributes(params[:work_relationship_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_relationship_type'))
        format.html { redirect_to(@work_relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_relationship_types/1
  # DELETE /work_relationship_types/1.xml
  def destroy
    @work_relationship_type = WorkRelationshipType.find(params[:id])
    @work_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(work_relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
