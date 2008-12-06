class MessageQueuesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  require_role 'Librarian'

  # GET /message_queues
  # GET /message_queues.xml
  def index
    @message_queues = MessageQueue.paginate(:all, :page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @message_queues }
    end
  end

  # GET /message_queues/1
  # GET /message_queues/1.xml
  def show
    @message_queue = MessageQueue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message_queue }
    end
  end

  # GET /message_queues/new
  # GET /message_queues/new.xml
  def new
    @message_queue = MessageQueue.new
    @message_templates = MessageTemplate.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message_queue }
    end
  end

  # GET /message_queues/1/edit
  def edit
    @message_queue = MessageQueue.find(params[:id])
    @message_templates = MessageTemplate.find(:all)
  end

  # POST /message_queues
  # POST /message_queues.xml
  def create
    @message_queue = MessageQueue.new(params[:message_queue])

    respond_to do |format|
      if @message_queue.save
        flash[:notice] = ('MessageQueue was successfully created.')
        format.html { redirect_to(@message_queue) }
        format.xml  { render :xml => @message_queue, :status => :created, :location => @message_queue }
      else
        @message_templates = MessageTemplate.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @message_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /message_queues/1
  # PUT /message_queues/1.xml
  def update
    @message_queue = MessageQueue.find(params[:id])

    respond_to do |format|
      if @message_queue.update_attributes(params[:message_queue])
        flash[:notice] = ('MessageQueue was successfully updated.')
        format.html { redirect_to(@message_queue) }
        format.xml  { head :ok }
      else
        @message_templates = MessageTemplate.find(:all)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message_queue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /message_queues/1
  # DELETE /message_queues/1.xml
  def destroy
    @message_queue = MessageQueue.find(params[:id])
    @message_queue.destroy

    respond_to do |format|
      format.html { redirect_to(message_queues_url) }
      format.xml  { head :ok }
    end
  end
end
