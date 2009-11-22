class ExpressionToManifestationRelTypesController < ApplicationController
  # GET /expression_to_manifestation_rel_types
  # GET /expression_to_manifestation_rel_types.xml
  def index
    @expression_to_manifestation_rel_types = ExpressionToManifestationRelType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expression_to_manifestation_rel_types }
    end
  end

  # GET /expression_to_manifestation_rel_types/1
  # GET /expression_to_manifestation_rel_types/1.xml
  def show
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expression_to_manifestation_rel_type }
    end
  end

  # GET /expression_to_manifestation_rel_types/new
  # GET /expression_to_manifestation_rel_types/new.xml
  def new
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression_to_manifestation_rel_type }
    end
  end

  # GET /expression_to_manifestation_rel_types/1/edit
  def edit
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.find(params[:id])
  end

  # POST /expression_to_manifestation_rel_types
  # POST /expression_to_manifestation_rel_types.xml
  def create
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.new(params[:expression_to_manifestation_rel_type])

    respond_to do |format|
      if @expression_to_manifestation_rel_type.save
        flash[:notice] = 'ExpressionToManifestationRelType was successfully created.'
        format.html { redirect_to(@expression_to_manifestation_rel_type) }
        format.xml  { render :xml => @expression_to_manifestation_rel_type, :status => :created, :location => @expression_to_manifestation_rel_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_to_manifestation_rel_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_to_manifestation_rel_types/1
  # PUT /expression_to_manifestation_rel_types/1.xml
  def update
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.find(params[:id])

    respond_to do |format|
      if @expression_to_manifestation_rel_type.update_attributes(params[:expression_to_manifestation_rel_type])
        flash[:notice] = 'ExpressionToManifestationRelType was successfully updated.'
        format.html { redirect_to(@expression_to_manifestation_rel_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_to_manifestation_rel_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_to_manifestation_rel_types/1
  # DELETE /expression_to_manifestation_rel_types/1.xml
  def destroy
    @expression_to_manifestation_rel_type = ExpressionToManifestationRelType.find(params[:id])
    @expression_to_manifestation_rel_type.destroy

    respond_to do |format|
      format.html { redirect_to(expression_to_manifestation_rel_types_url) }
      format.xml  { head :ok }
    end
  end
end
