class WorkHasWorksController < ApplicationController
  load_and_authorize_resource
  before_filter :get_work
  before_filter :prepare_options, :only => [:new, :edit]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /work_has_works
  # GET /work_has_works.xml
  def index
    if @work
      if params[:mode] == 'add'
        @work_has_works = WorkHasWork.paginate(:all, :page => params[:page])
      else
        @work_has_works = @work.to_works.paginate(:all, :page => params[:page])
      end
    else
      @work_has_works = WorkHasWork.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_has_works }
    end
  end

  # GET /work_has_works/1
  # GET /work_has_works/1.xml
  def show
    @work_has_work = WorkHasWork.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_has_work }
    end
  end

  # GET /work_has_works/new
  # GET /work_has_works/new.xml
  def new
    @work_has_work = WorkHasWork.new
    @work_has_work.from_work = @work
    @work_has_work.to_work = Work.find(params[:to_work_id]) rescue nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_has_work }
    end
  end

  # GET /work_has_works/1/edit
  def edit
    @work_has_work = WorkHasWork.find(params[:id])
  end

  # POST /work_has_works
  # POST /work_has_works.xml
  def create
    @work_has_work = WorkHasWork.new(params[:work_has_work])

    respond_to do |format|
      if @work_has_work.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_has_work'))
        format.html { redirect_to(@work_has_work) }
        format.xml  { render :xml => @work_has_work, :status => :created, :location => @work_has_work }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_has_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_has_works/1
  # PUT /work_has_works/1.xml
  def update
    @work_has_work = WorkHasWork.find(params[:id])

    respond_to do |format|
      if @work_has_work.update_attributes(params[:work_has_work])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_has_work'))
        format.html { redirect_to(@work_has_work) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_has_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_has_works/1
  # DELETE /work_has_works/1.xml
  def destroy
    @work_has_work = WorkHasWork.find(params[:id])
    @work_has_work.destroy

    respond_to do |format|
      format.html { redirect_to(work_has_works_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @work_relationship_types = WorkRelationshipType.all
  end
end
