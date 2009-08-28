class ExpressionHasExpressionsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_expression
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /expression_has_expressions
  # GET /expression_has_expressions.xml
  def index
    if @expression
      if params[:mode] == 'add'
        @expression_has_expressions = ExpressionHasExpression.paginate(:all, :page => params[:page])
      else
        @expression_has_expressions = @expression.to_expressions.paginate(:all, :page => params[:page])
      end
    else
      @expression_has_expressions = ExpressionHasExpression.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expression_has_expressions }
    end
  end

  # GET /expression_has_expressions/1
  # GET /expression_has_expressions/1.xml
  def show
    @expression_has_expression = ExpressionHasExpression.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expression_has_expression }
    end
  end

  # GET /expression_has_expressions/new
  # GET /expression_has_expressions/new.xml
  def new
    @expression_has_expression = ExpressionHasExpression.new
    @expression_has_expression.from_expression = @expression
    @expression_has_expression.to_expression = Expression.find(params[:to_expression_id]) rescue nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression_has_expression }
    end
  end

  # GET /expression_has_expressions/1/edit
  def edit
    @expression_has_expression = ExpressionHasExpression.find(params[:id])
  end

  # POST /expression_has_expressions
  # POST /expression_has_expressions.xml
  def create
    @expression_has_expression = ExpressionHasExpression.new(params[:expression_has_expression])

    respond_to do |format|
      if @expression_has_expression.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression_has_expression'))
        format.html { redirect_to(@expression_has_expression) }
        format.xml  { render :xml => @expression_has_expression, :status => :created, :location => @expression_has_expression }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_has_expression.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_has_expressions/1
  # PUT /expression_has_expressions/1.xml
  def update
    @expression_has_expression = ExpressionHasExpression.find(params[:id])

    respond_to do |format|
      if @expression_has_expression.update_attributes(params[:expression_has_expression])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expression_has_expression'))
        format.html { redirect_to(@expression_has_expression) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_has_expression.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_has_expressions/1
  # DELETE /expression_has_expressions/1.xml
  def destroy
    @expression_has_expression = ExpressionHasExpression.find(params[:id])
    @expression_has_expression.destroy

    respond_to do |format|
      format.html { redirect_to(expression_has_expressions_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @expression_relationship_types = ExpressionRelationshipType.all
  end
end
