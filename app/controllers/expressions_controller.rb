# -*- encoding: utf-8 -*-
class ExpressionsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_work, :get_manifestation
  before_filter :get_expression, :only => :index
  before_filter :get_expression_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_version, :only => [:show]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

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
      search.build do
        fulltext query
      end
    end

    set_role_query(current_user, search)

    unless params[:mode] == 'add'
      manifestation = @manifestation
      patron = @patron
      work = @work
      expression = @expression
      expression_merge_list = @expression_merge_list
      search.build do
        with(:manifestation_ids).equal_to manifestation.id if manifestation
        with(:patron_ids).equal_to patron.id if patron
        with(:work_id).equal_to work.id if work
        with(:original_expression_ids).equal_to expression.id if expression
        with(:expression_merge_list_ids).equal_to expression_merge_list.id if expression_merge_list
      end
    end

    role = current_user.try(:role) || Role.find(1)
    search.build do
      with(:required_role_id).less_than role.id
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Expression.per_page)
    begin
      @expressions = search.execute!.results
    rescue RSolr::RequestError
      @expressions = WillPaginate::Collection.create(1,1,0) do end
    end
    @count[:total] = @expressions.total_entries

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @expressions }
      format.atom
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to expressions_url
    return
  end

  # GET /expressions/1
  # GET /expressions/1.xml
  def show
    case when @work
      @expression = @work.expressions.find(params[:id])
    when @manifestation
      @expression = @manifestation.expressions.find(params[:id])
    when @patron
      @expression = @patron.expressions.find(params[:id])
    #else
    #  @expression = Expression.find(params[:id])
    end
    @expression = @expression.versions.find(@version).item if @version

    canonical_url expression_url(@expression)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @expression }
    end
  end

  # GET /expressions/new
  def new
    #unless @work
    #  flash[:notice] = t('expression.specify_work')
    #  redirect_to works_path
    #  return
    #end
    @expression = Expression.new
    if @work
      @expression.original_title = @work.original_title
      @expression.title_transcription = @work.title_transcription
    end
    @expression.language = Language.first(:conditions => {:iso_639_1 => @locale})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression }
    end
  end

  # GET /expressions/1;edit
  def edit
    #@expression = Expression.find(params[:id])
  end

  # POST /expressions
  # POST /expressions.xml
  def create
    unless @work
      flash[:notice] = t('expression.specify_work')
      redirect_to works_path
      return
    end
    @expression = Expression.new(params[:expression])

    respond_to do |format|
      if @expression.save
        Expression.transaction do
          @work.expressions << @expression
          #if @expression.serial?
          #  @expression.patrons << @work.patrons
          #end
        end

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.expression'))
        format.html { redirect_to @expression }
        format.xml  { render :xml => @expression, :status => :created, :location => @expression }
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
    #@expression = Expression.find(params[:id])
    params[:issn] = params[:issn].gsub(/\D/, "") if params[:issn]

    respond_to do |format|
      if @expression.update_attributes(params[:expression])
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
    #@expression = Expression.find(params[:id])
    @expression.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.expression'))
      format.html { redirect_to expressions_url }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    if Rails.env == 'production'
      @content_types = Rails.cache.fetch('ContentType.all'){ContentType.all}
      @languages = Rails.cache.fetch('Language.all'){Language.all}
      @roles = Rails.cache.fetch('Role.all'){Role.all}
    else
      @content_types = ContentType.all
      @languages = Language.all
      @roles = Role.all
    end
  end
end
