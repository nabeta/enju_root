class ExpressionsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_work, :get_manifestation, :get_subscription
  before_filter :get_expression_merge_list
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /expressions
  # GET /expressions.xml
  def index
    @query = params[:query].to_s.strip
    unless @query.blank?
      @count = {}
      query = @query
      query = "#{query} frequency_of_issue_id: [2 TO *]" if params[:view] == 'serial'
      unless params[:mode] == 'add'
        query += " manifestation_ids: #{@manifestation.id}" if @manifestation
        query += " patron_ids: #{@patron.id}" if @patron
        query += " work_id: #{@work.id}" if @work
        query += " subscription_id: #{@subscription.id}" if @subscription
        query += " expression_merge_list_ids: #{@expression_merge_list.id}" if @expression_merge_list
      end
      @expressions = Expression.paginate_by_solr(query, :facets => {:zeros => true, :fields => [:language_id]}, :page => params[:page], :per_page => @per_page).compact
      @count[:total] = @expressions.total_entries
    else
      case
      when @patron
        @expressions = @patron.expressions.paginate(:page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      when @work
        @expressions = @work.expressions.paginate(:page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      when @manifestation
        @expressions = @manifestation.expressions.paginate(:page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      when @subscription
        @expressions = @subscription.expressions.paginate(:page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      when @expression_merge_list
        @expressions = @expression_merge_list.expressions.paginate(:page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      else
        raise ActiveRecord::RecordNotFound if params[:patron_id] or params[:manifestation_id]
        @expressions = Expression.paginate(:all, :page => params[:page], :per_page => @per_page, :include => [:expression_form, :language], :order => 'expressions.id')
      end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @expressions }
      format.atom
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /expressions/1
  # GET /expressions/1.xml
  def show
    if params[:issn]
      issn = params[:issn].strip
      @expression = Expression.find(:first, :conditions => {:issn => issn})
      redirect_to @expression and return
    else
      case when @work
        @expression = @work.expressions.find(params[:id])
      when @manifestation
        @expression = @manifestation.expressions.find(params[:id])
      when @patron
        @expression = @patron.expressions.find(params[:id])
      else
        @expression = Expression.find(params[:id])
      end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @expression }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /expressions/new
  def new
    unless @work
      flash[:notice] = ('Specify work id.')
      redirect_to works_path
      return
    end
    @languages = Language.find(:all, :order => :id)
    @expression_forms = ExpressionForm.find(:all)
    @parent_expression = Expression.find(params[:parent_id]) rescue nil
    @frequency_of_issues = FrequencyOfIssue.find(:all)
    @expression = Expression.new
  end

  # GET /expressions/1;edit
  def edit
    @languages = Language.find(:all, :order => :id)
    @expression_forms = ExpressionForm.find(:all)
    @frequency_of_issues = FrequencyOfIssue.find(:all)
    @parent = Expression.find(params[:parent_id]) rescue nil
    
    @expression = Expression.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /expressions
  # POST /expressions.xml
  def create
    unless @work
      flash[:notice] = ('Specify work id.')
      redirect_to works_path
      return
    end
    params[:issn] = params[:issn].gsub(/\D/, "") if params[:issn]
    @expression = Expression.new(params[:expression])

    respond_to do |format|
      if @expression.save
        Expression.transaction do
          @work.expressions << @expression
          if @expression.serial?
            @expression.patrons << @work.patrons
          end
        end

        flash[:notice] = ('Expression was successfully created.')
        if @expression.patrons.blank?
          format.html { redirect_to expression_patrons_url(@expression) }
          format.xml  { head :created, :location => patron_expression_url(@patron, @expression) }
        else
          format.html { redirect_to work_expression_url(@work, @expression) }
          format.xml  { head :created, :location => work_expression_url(@work, @expression) }
        end
      else
        @languages = Language.find(:all, :order => :id)
        @frequency_of_issues = FrequencyOfIssue.find(:all)
        @expression_forms = ExpressionForm.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expressions/1
  # PUT /expressions/1.xml
  def update
    @expression = Expression.find(params[:id])
    params[:issn] = params[:issn].gsub(/\D/, "") if params[:issn]

    respond_to do |format|
      if @expression.update_attributes(params[:expression])
        flash[:notice] = ('Expression was successfully updated.')
        format.html { redirect_to expression_url(@expression) }
        format.xml  { head :ok }
      else
        @languages = Language.find(:all, :order => :id)
        @frequency_of_issues = FrequencyOfIssue.find(:all)
        @expression_forms = ExpressionForm.find(:all)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expressions/1
  # DELETE /expressions/1.xml
  def destroy
    @expression = Expression.find(params[:id])
    @expression.destroy

    respond_to do |format|
      format.html { redirect_to expressions_url }
      format.xml  { head :ok }
    end
  end
end
