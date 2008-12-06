class SearchEnginesController < ApplicationController
  before_filter :login_required
  require_role 'Administrator'

  # GET /search_engines
  # GET /search_engines.xml
  def index
    @search_engines = SearchEngine.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @search_engines }
    end
  end

  # GET /search_engines/1
  # GET /search_engines/1.xml
  def show
    @search_engine = SearchEngine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search_engine }
    end
  end

  # GET /search_engines/new
  # GET /search_engines/new.xml
  def new
    @search_engine = SearchEngine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @search_engine }
    end
  end

  # GET /search_engines/1/edit
  def edit
    @search_engine = SearchEngine.find(params[:id])
  end

  # POST /search_engines
  # POST /search_engines.xml
  def create
    @search_engine = SearchEngine.new(params[:search_engine])

    respond_to do |format|
      if @search_engine.save
        flash[:notice] = ('SearchEngine was successfully created.')
        format.html { redirect_to(@search_engine) }
        format.xml  { render :xml => @search_engine, :status => :created, :location => @search_engine }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @search_engine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /search_engines/1
  # PUT /search_engines/1.xml
  def update
    @search_engine = SearchEngine.find(params[:id])

    if @search_engine and params[:position]
      @search_engine.insert_at(params[:position])
      redirect_to search_engines_url
      return
    end

    respond_to do |format|
      if @search_engine.update_attributes(params[:search_engine])
        flash[:notice] = ('SearchEngine was successfully updated.')
        format.html { redirect_to(@search_engine) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @search_engine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /search_engines/1
  # DELETE /search_engines/1.xml
  def destroy
    @search_engine = SearchEngine.find(params[:id])
    @search_engine.destroy

    respond_to do |format|
      format.html { redirect_to(search_engines_url) }
      format.xml  { head :ok }
    end
  end
end
