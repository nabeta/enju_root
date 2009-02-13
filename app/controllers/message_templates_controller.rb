class MessageTemplatesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  require_role 'Librarian'

  # GET /message_templates
  # GET /message_templates.xml
  def index
    @message_templates = MessageTemplate.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @message_templates }
    end
  end

  # GET /message_templates/1
  # GET /message_templates/1.xml
  def show
    @message_template = MessageTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message_template }
    end
  end

  # GET /message_templates/new
  # GET /message_templates/new.xml
  def new
    @message_template = MessageTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message_template }
    end
  end

  # GET /message_templates/1/edit
  def edit
    @message_template = MessageTemplate.find(params[:id])
  end

  # POST /message_templates
  # POST /message_templates.xml
  def create
    @message_template = MessageTemplate.new(params[:message_template])

    respond_to do |format|
      if @message_template.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.message_template'))
        format.html { redirect_to(@message_template) }
        format.xml  { render :xml => @message_template, :status => :created, :location => @message_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /message_templates/1
  # PUT /message_templates/1.xml
  def update
    @message_template = MessageTemplate.find(params[:id])

    if @message_template and params[:position]
      @message_template.insert_at(params[:position])
      redirect_to message_templates_url
      return
    end

    respond_to do |format|
      if @message_template.update_attributes(params[:message_template])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.message_template'))
        format.html { redirect_to(@message_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /message_templates/1
  # DELETE /message_templates/1.xml
  def destroy
    @message_template = MessageTemplate.find(params[:id])
    @message_template.destroy

    respond_to do |format|
      format.html { redirect_to(message_templates_url) }
      format.xml  { head :ok }
    end
  end
end
