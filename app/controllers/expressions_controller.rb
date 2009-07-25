class ExpressionsController < ApplicationController
  before_filter :has_permission?, :except => :show
  before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_work, :get_manifestation, :get_subscription
  before_filter :get_expression, :only => :index
  before_filter :get_expression_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /expressions
  # GET /expressions.xml
  def index
    query = params[:query].to_s.strip
    search = Sunspot.new_search(Expression)
    @count = {}
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      #query = "#{query} frequency_of_issue_id: [2 TO *]" if params[:view] == 'serial'
      search.query.keywords = query
    end
    unless params[:mode] == 'add'
      search.query.add_restriction(:manifestation_ids, :equal_to, @manifestation.id) if @manifestation
      search.query.add_restriction(:patron_ids, :equal_to, @patron.id) if @patron
      search.query.add_restriction(:work_id, :equal_to, @work.id) if @work
      search.query.add_restriction(:original_expression_ids, :equal_to, @expression.id) if @expression
      search.query.add_restriction(:expression_merge_ids, :equal_to, @expression_merge_list.id) if @expression_merge_list

    end
    page = params[:page] || 1
    search.query.paginate(page.to_i, Expression.per_page)
    begin
      @expressions = search.execute!.results
    rescue
      @expressions = WillPaginate::Collection.create(1,1,0) do end
    end
    @count[:total] = @expressions.total_entries

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @expressions }
      format.atom
    end
  #rescue ActiveRecord::RecordNotFound
  #  not_found
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

    canonical_url expression_url(@expression)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @expression }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /expressions/new
  def new
    #unless @work
    #  flash[:notice] = t('expression.specify_work')
    #  redirect_to works_path
    #  return
    #end
    @parent_expression = Expression.find(params[:parent_id]) rescue nil
    @expression = Expression.new
    @expression.language = Language.find(:first, :conditions => {:iso_639_1 => @locale})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression }
    end
  end

  # GET /expressions/1;edit
  def edit
    @parent = Expression.find(params[:parent_id]) rescue nil
    
    @expression = Expression.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /expressions
  # POST /expressions.xml
  def create
    unless @work
      flash[:notice] = t('expression.specify_work')
      redirect_to works_path
      return
    end
    params[:issn] = params[:issn].gsub(/\D/, "") if params[:issn]
    @expression = Expression.new(params[:expression])

    respond_to do |format|
      if @expression.save
        @expression.index
        Expression.transaction do
          @work.expressions << @expression
          #if @expression.serial?
          #  @expression.patrons << @work.patrons
          #end
        end

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression'))
        if @expression.patrons.empty?
          format.html { redirect_to expression_patrons_url(@expression) }
          format.xml  { render :xml => @expression, :status => :created, :location => @expression }
        else
          format.html { redirect_to work_expression_url(@work, @expression) }
          format.xml  { render :xml => @expression, :status => :created, :location => work_expression_url(@work, @expression) }
        end
      else
        prepare_options
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
        @expression.index
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.expression'))
        format.html { redirect_to expression_url(@expression) }
        format.xml  { head :ok }
      else
        prepare_options
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
    @expression.remove_from_index

    respond_to do |format|
      format.html { redirect_to expressions_url }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @expression_forms = ExpressionForm.find(:all)
    @languages = Rails.cache.fetch('Language.all'){Language.all}
  end
end
