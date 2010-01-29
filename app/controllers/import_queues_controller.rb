class ImportQueuesController < ApplicationController
  before_filter :has_permission?

  # GET /import_queues
  # GET /import_queues.xml
  def index
    @import_queues = ImportQueue.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @import_queues }
    end
  end

  # GET /import_queues/1
  # GET /import_queues/1.xml
  def show
    @import_queue = ImportQueue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @import_queue }
    end
  end

  # GET /import_queues/new
  # GET /import_queues/new.xml
  def new
    @import_queue = ImportQueue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @import_queue }
    end
  end

  # GET /import_queues/1/edit
  def edit
    @import_queue = ImportQueue.find(params[:id])
  end

  # POST /import_queues
  # POST /import_queues.xml
  def create
    @import_queue = ImportQueue.new(params[:import_queue])

    respond_to do |format|
      if @import_queue.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.import_queue'))
        format.html { redirect_to(@import_queue) }
        format.xml  { render :xml => @import_queue, :status => :created, :location => @import_queue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @import_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /import_queues/1
  # PUT /import_queues/1.xml
  def update
    @import_queue = ImportQueue.find(params[:id])

    respond_to do |format|
      if @import_queue.update_attributes(params[:import_queue])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.import_queue'))
        format.html { redirect_to(@import_queue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @import_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /import_queues/1
  # DELETE /import_queues/1.xml
  def destroy
    @import_queue = ImportQueue.find(params[:id])
    @import_queue.destroy

    respond_to do |format|
      format.html { redirect_to(import_queues_url) }
      format.xml  { head :ok }
    end
  end
end
