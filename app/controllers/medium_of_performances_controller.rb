class MediumOfPerformancesController < ApplicationController
  before_filter :has_permission?

  # GET /medium_of_performances
  # GET /medium_of_performances.xml
  def index
    @medium_of_performances = MediumOfPerformance.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @medium_of_performances }
    end
  end

  # GET /medium_of_performances/1
  # GET /medium_of_performances/1.xml
  def show
    @medium_of_performance = MediumOfPerformance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @medium_of_performance }
    end
  end

  # GET /medium_of_performances/new
  # GET /medium_of_performances/new.xml
  def new
    @medium_of_performance = MediumOfPerformance.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @medium_of_performance }
    end
  end

  # GET /medium_of_performances/1/edit
  def edit
    @medium_of_performance = MediumOfPerformance.find(params[:id])
  end

  # POST /medium_of_performances
  # POST /medium_of_performances.xml
  def create
    @medium_of_performance = MediumOfPerformance.new(params[:medium_of_performance])

    respond_to do |format|
      if @medium_of_performance.save
        flash[:notice] = 'MediumOfPerformance was successfully created.'
        format.html { redirect_to(@medium_of_performance) }
        format.xml  { render :xml => @medium_of_performance, :status => :created, :location => @medium_of_performance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @medium_of_performance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /medium_of_performances/1
  # PUT /medium_of_performances/1.xml
  def update
    @medium_of_performance = MediumOfPerformance.find(params[:id])

    if @medium_of_performance and params[:position]
      @medium_of_performance.insert_at(params[:position])
      redirect_to medium_of_performances_url
      return
    end

    respond_to do |format|
      if @medium_of_performance.update_attributes(params[:medium_of_performance])
        flash[:notice] = 'MediumOfPerformance was successfully updated.'
        format.html { redirect_to(@medium_of_performance) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @medium_of_performance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /medium_of_performances/1
  # DELETE /medium_of_performances/1.xml
  def destroy
    @medium_of_performance = MediumOfPerformance.find(params[:id])
    @medium_of_performance.destroy

    respond_to do |format|
      format.html { redirect_to(medium_of_performances_url) }
      format.xml  { head :ok }
    end
  end
end
