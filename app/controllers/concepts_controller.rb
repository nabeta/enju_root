class ConceptsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /concepts
  # GET /concepts.xml
  def index
    @concepts = Concept.paginate(:all, :page => params[:page])

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
