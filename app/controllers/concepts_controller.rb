class ConceptsController < ApplicationController
  before_filter :has_permission?
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /concepts
  # GET /concepts.xml
  def index
    if params[:query]
      @query = params[:query]
      flash[:query] = @query
    end

    if @query.blank?
      @concepts = Concept.paginate(:all, :page => params[:page])
    else
      @concepts = Concept.paginate_by_solr(@query, :page => params[:page], :per_page => @per_page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @concepts }
    end
  end

  # GET /concepts/1
  # GET /concepts/1.xml
  def show
    @concept = Concept.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @concept }
    end
  end

  # GET /concepts/new
  # GET /concepts/new.xml
  def new
    @concept = Concept.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @concept }
    end
  end

  # GET /concepts/1/edit
  def edit
    @concept = Concept.find(params[:id])
  end

  # POST /concepts
  # POST /concepts.xml
  def create
    @concept = Concept.new(params[:concept])

    respond_to do |format|
      if @concept.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.concept'))
        format.html { redirect_to(@concept) }
        format.xml  { render :xml => @concept, :status => :created, :location => @concept }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @concept.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /concepts/1
  # PUT /concepts/1.xml
  def update
    @concept = Concept.find(params[:id])

    respond_to do |format|
      if @concept.update_attributes(params[:concept])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.concept'))
        format.html { redirect_to(@concept) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @concept.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /concepts/1
  # DELETE /concepts/1.xml
  def destroy
    @concept = Concept.find(params[:id])
    @concept.destroy

    respond_to do |format|
      format.html { redirect_to(concepts_url) }
      format.xml  { head :ok }
    end
  end
end
