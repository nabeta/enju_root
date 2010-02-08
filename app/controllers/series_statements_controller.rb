class SeriesStatementsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_manifestation, :only => [:index, :new, :edit]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /series_statements
  # GET /series_statements.xml
  def index
    search = Sunspot.new_search(SeriesStatement)
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.build do
        fulltext query
      end
    end
    page = params[:page] || 1
    search.query.paginate(page.to_i, SeriesStatement.per_page)
    begin
      @series_statements = search.execute!.results
    rescue RSolr::RequestError
      @series_statements = WillPaginate::Collection.create(1,1,0) do end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @series_statements }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to series_statements_url
    return
  end

  # GET /series_statements/1
  # GET /series_statements/1.xml
  def show
    @series_statement = SeriesStatement.find(params[:id])
    @manifestations = @series_statement.manifestations.paginate(:page => params[:manifestation_page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @series_statement }
      format.js {
        render :update do |page|
          page.replace_html 'manifestation_list', :partial => 'manifestation_list' if params[:manifestation_page]
        end
      }
    end
  end

  # GET /series_statements/new
  # GET /series_statements/new.xml
  def new
    @series_statement = SeriesStatement.new
    @series_statement.manifestation_id = @manifestation.id if @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @series_statement }
    end
  end

  # GET /series_statements/1/edit
  def edit
    @series_statement = SeriesStatement.find(params[:id])
  end

  # POST /series_statements
  # POST /series_statements.xml
  def create
    @series_statement = SeriesStatement.new(params[:series_statement])
    manifestation = Manifestation.find(@series_statement.manifestation_id) rescue nil

    respond_to do |format|
      if @series_statement.save
        @series_statement.manifestations << manifestation if manifestation
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.series_statement'))
        format.html { redirect_to(@series_statement) }
        format.xml  { render :xml => @series_statement, :status => :created, :location => @series_statement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @series_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series_statements/1
  # PUT /series_statements/1.xml
  def update
    @series_statement = SeriesStatement.find(params[:id])

    respond_to do |format|
      if @series_statement.update_attributes(params[:series_statement])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.series_statement'))
        format.html { redirect_to(@series_statement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @series_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statements/1
  # DELETE /series_statements/1.xml
  def destroy
    @series_statement = SeriesStatement.find(params[:id])
    @series_statement.destroy

    respond_to do |format|
      format.html { redirect_to(series_statements_url) }
      format.xml  { head :ok }
    end
  end
end
