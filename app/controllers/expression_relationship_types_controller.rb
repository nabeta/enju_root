class ExpressionRelationshipTypesController < ApplicationController
  load_and_authorize_resource

  # GET /expression_relationship_types
  # GET /expression_relationship_types.xml
  def index
    @expression_relationship_types = ExpressionRelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expression_relationship_types }
    end
  end

  # GET /expression_relationship_types/1
  # GET /expression_relationship_types/1.xml
  def show
    @expression_relationship_type = ExpressionRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expression_relationship_type }
    end
  end

  # GET /expression_relationship_types/new
  # GET /expression_relationship_types/new.xml
  def new
    @expression_relationship_type = ExpressionRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression_relationship_type }
    end
  end

  # GET /expression_relationship_types/1/edit
  def edit
    @expression_relationship_type = ExpressionRelationshipType.find(params[:id])
  end

  # POST /expression_relationship_types
  # POST /expression_relationship_types.xml
  def create
    @expression_relationship_type = ExpressionRelationshipType.new(params[:expression_relationship_type])

    respond_to do |format|
      if @expression_relationship_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression_relationship_type'))
        format.html { redirect_to(@expression_relationship_type) }
        format.xml  { render :xml => @expression_relationship_type, :status => :created, :location => @expression_relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_relationship_types/1
  # PUT /expression_relationship_types/1.xml
  def update
    @expression_relationship_type = ExpressionRelationshipType.find(params[:id])

    if @expression_relationship_type and params[:position]
      @expression_relationship_type.insert_at(params[:position])
      redirect_to expression_relationship_types_url
      return
    end

    respond_to do |format|
      if @expression_relationship_type.update_attributes(params[:expression_relationship_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expression_relationship_type'))
        format.html { redirect_to(@expression_relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_relationship_types/1
  # DELETE /expression_relationship_types/1.xml
  def destroy
    @expression_relationship_type = ExpressionRelationshipType.find(params[:id])
    @expression_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(expression_relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
