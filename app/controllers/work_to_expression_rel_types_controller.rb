class WorkToExpressionRelTypesController < ApplicationController
  before_filter :has_permission?

  # GET /work_to_expression_rel_types
  # GET /work_to_expression_rel_types.xml
  def index
    @work_to_expression_rel_types = WorkToExpressionRelType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_to_expression_rel_types }
    end
  end

  # GET /work_to_expression_rel_types/1
  # GET /work_to_expression_rel_types/1.xml
  def show
    @work_to_expression_rel_type = WorkToExpressionRelType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_to_expression_rel_type }
    end
  end

  # GET /work_to_expression_rel_types/new
  # GET /work_to_expression_rel_types/new.xml
  def new
    @work_to_expression_rel_type = WorkToExpressionRelType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_to_expression_rel_type }
    end
  end

  # GET /work_to_expression_rel_types/1/edit
  def edit
    @work_to_expression_rel_type = WorkToExpressionRelType.find(params[:id])
  end

  # POST /work_to_expression_rel_types
  # POST /work_to_expression_rel_types.xml
  def create
    @work_to_expression_rel_type = WorkToExpressionRelType.new(params[:work_to_expression_rel_type])

    respond_to do |format|
      if @work_to_expression_rel_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_to_expression_rel_type'))
        format.html { redirect_to(@work_to_expression_rel_type) }
        format.xml  { render :xml => @work_to_expression_rel_type, :status => :created, :location => @work_to_expression_rel_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_to_expression_rel_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_to_expression_rel_types/1
  # PUT /work_to_expression_rel_types/1.xml
  def update
    @work_to_expression_rel_type = WorkToExpressionRelType.find(params[:id])

    respond_to do |format|
      if @work_to_expression_rel_type.update_attributes(params[:work_to_expression_rel_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_to_expression_rel_type'))
        format.html { redirect_to(@work_to_expression_rel_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_to_expression_rel_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_to_expression_rel_types/1
  # DELETE /work_to_expression_rel_types/1.xml
  def destroy
    @work_to_expression_rel_type = WorkToExpressionRelType.find(params[:id])
    @work_to_expression_rel_type.destroy

    respond_to do |format|
      format.html { redirect_to(work_to_expression_rel_types_url) }
      format.xml  { head :ok }
    end
  end
end
