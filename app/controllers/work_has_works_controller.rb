class WorkHasWorksController < ApplicationController
  before_filter :has_permission?

  # GET /work_has_works
  # GET /work_has_works.xml
  def index
    @work_has_works = WorkHasWork.find(:all)

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
        flash[:notice] = 'WorkHasWork was successfully created.'
        format.html { redirect_to(@work_has_work) }
        format.xml  { render :xml => @work_has_work, :status => :created, :location => @work_has_work }
      else
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
        flash[:notice] = 'WorkHasWork was successfully updated.'
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
end
