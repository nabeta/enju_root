class PlacesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /subjects
  # GET /subjects.xml
  def index
    if params[:query]
      @query = params[:query]
      flash[:query] = @query
    end

    if @query.blank?
      @subjects = Place.paginate(:all, :page => params[:page])
    else
      @subjects = Place.paginate_by_solr(@query, :page => params[:page], :per_page => @per_page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    @subject = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.xml
  def new
    @subject = Place.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Place.find(params[:id])
  end

  # POST /subjects
  # POST /subjects.xml
  def create
    @subject = Place.new(params[:subject])

    respond_to do |format|
      if @subject.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.subject'))
        format.html { redirect_to(@subject) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.xml
  def update
    @subject = Place.find(params[:id])

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.subject'))
        format.html { redirect_to(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.xml
  def destroy
    @subject = Place.find(params[:id])
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
