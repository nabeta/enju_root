class SeriesStatementsController < ApplicationController
  before_filter :has_permission?

  # GET /series_statements
  # GET /series_statements.xml
  def index
    @series_statements = SeriesStatement.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @series_statements }
    end
  end

  # GET /series_statements/1
  # GET /series_statements/1.xml
  def show
    @series_statement = SeriesStatement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @series_statement }
    end
  end

  # GET /series_statements/new
  # GET /series_statements/new.xml
  def new
    @series_statement = SeriesStatement.new

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

    respond_to do |format|
      if @series_statement.save
        flash[:notice] = 'SeriesStatement was successfully created.'
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
        flash[:notice] = 'SeriesStatement was successfully updated.'
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
