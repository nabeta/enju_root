class ReifiesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_work, :get_expression
  before_filter :prepare_options, :only => [:new, :edit]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /reifies
  # GET /reifies.xml
  def index
    if @work
      @reifies = @work.reifies.paginate(:page => params[:page])
    else
      @reifies = Reify.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @reifies }
    end
  end

  # GET /reifies/1
  # GET /reifies/1.xml
  def show
    @reify = Reify.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @reify }
    end
  end

  # GET /reifies/new
  def new
    @reify = Reify.new
    @reify.work = @work
    @reify.expression = @expression
  end

  # GET /reifies/1/edit
  def edit
    @reify = Reify.find(params[:id])
  end

  # POST /reifies
  # POST /reifies.xml
  def create
    @reify = Reify.new(params[:reify])

    respond_to do |format|
      if @reify.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reify'))
        format.html { redirect_to(@reify) }
        format.xml  { render :xml => @reify, :status => :created, :location => @reify }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @reify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reifies/1
  # PUT /reifies/1.xml
  def update
    @reify = Reify.find(params[:id])
    
    # 並べ替え
    if @expression and params[:position]
      @reify.insert_at(params[:position])
      redirect_to expression_reifies_url(@expression)
      return
    end

    respond_to do |format|
      if @reify.update_attributes(params[:reify])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reify'))
        format.html { redirect_to reify_url(@reify) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reify.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reifies/1
  # DELETE /reifies/1.xml
  def destroy
    @reify = Reify.find(params[:id])
    @reify.destroy

    respond_to do |format|
      if @work
        format.html { redirect_to work_expressions_url(@work) }
        format.xml  { head :ok }
      else
        format.html { redirect_to reifies_url }
        format.xml  { head :ok }
      end
    end
  end

  private
  def prepare_options
    @work_to_expression_rel_types = WorkToExpressionRelType.all
  end
end
