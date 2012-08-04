class ExpressionMergesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_expression, :get_expression_merge_list

  # GET /expression_merges
  # GET /expression_merges.json
  def index
    if @expression
      @expression_merges = @expression.expression_merges.order('expression_merges.id').page(params[:page])
    elsif @expression_merge_list
      @expression_merges = @expression_merge_list.expression_merges.order('expression_merges.id').page(params[:page])
    else
      @expression_merges = ExpressionMerge.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @expression_merges }
    end
  end

  # GET /expression_merges/1
  # GET /expression_merges/1.json
  def show
    @expression_merge = ExpressionMerge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @expression_merge }
    end
  end

  # GET /expression_merges/new
  # GET /expression_merges/new.json
  def new
    @expression_merge = ExpressionMerge.new
    @expression_merge.expression = @expression if @expression

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @expression_merge }
    end
  end

  # GET /expression_merges/1/edit
  def edit
    @expression_merge = ExpressionMerge.find(params[:id])
  end

  # POST /expression_merges
  # POST /expression_merges.json
  def create
    @expression_merge = ExpressionMerge.new(params[:expression_merge])

    respond_to do |format|
      if @expression_merge.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression_merge'))
        format.html { redirect_to(@expression_merge) }
        format.json { render :json => @expression_merge, :status => :created, :location => @expression_merge }
      else
        format.html { render :action => "new" }
        format.json { render :json => @expression_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_merges/1
  # PUT /expression_merges/1.json
  def update
    @expression_merge = ExpressionMerge.find(params[:id])

    respond_to do |format|
      if @expression_merge.update_attributes(params[:expression_merge])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expression_merge'))
        format.html { redirect_to(@expression_merge) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @expression_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_merges/1
  # DELETE /expression_merges/1.json
  def destroy
    @expression_merge = ExpressionMerge.find(params[:id])
    @expression_merge.destroy

    respond_to do |format|
      format.html { redirect_to(expression_merges_url) }
      format.json { head :no_content }
    end
  end
end
