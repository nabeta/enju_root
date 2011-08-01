class ExpressionMergesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_expression, :get_expression_merge_list

  # GET /expression_merges
  # GET /expression_merges.xml
  def index
    if @expression
      @expression_merges = @expression.expression_merges.paginate(:page => params[:page], :order => ['expression_merges.id'])
    elsif @expression_merge_list
      @expression_merges = @expression_merge_list.expression_merges.paginate(:page => params[:page], :include => 'expression', :order => ['expression_merges.id'])
    else
      @expression_merges = ExpressionMerge.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expression_merges }
    end
  end

  # GET /expression_merges/1
  # GET /expression_merges/1.xml
  def show
    @expression_merge = ExpressionMerge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expression_merge }
    end
  end

  # GET /expression_merges/new
  # GET /expression_merges/new.xml
  def new
    @expression_merge = ExpressionMerge.new
    @expression_merge.expression = @expression if @expression

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression_merge }
    end
  end

  # GET /expression_merges/1/edit
  def edit
    @expression_merge = ExpressionMerge.find(params[:id])
  end

  # POST /expression_merges
  # POST /expression_merges.xml
  def create
    @expression_merge = ExpressionMerge.new(params[:expression_merge])

    respond_to do |format|
      if @expression_merge.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression_merge'))
        format.html { redirect_to(@expression_merge) }
        format.xml  { render :xml => @expression_merge, :status => :created, :location => @expression_merge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_merges/1
  # PUT /expression_merges/1.xml
  def update
    @expression_merge = ExpressionMerge.find(params[:id])

    respond_to do |format|
      if @expression_merge.update_attributes(params[:expression_merge])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expression_merge'))
        format.html { redirect_to(@expression_merge) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_merges/1
  # DELETE /expression_merges/1.xml
  def destroy
    @expression_merge = ExpressionMerge.find(params[:id])
    @expression_merge.destroy

    respond_to do |format|
      format.html { redirect_to(expression_merges_url) }
      format.xml  { head :ok }
    end
  end
end
