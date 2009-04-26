class UseRestrictionsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?

  # GET /use_restrictions
  # GET /use_restrictions.xml
  def index
    @use_restrictions = UseRestriction.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @use_restrictions }
    end
  end

  # GET /use_restrictions/1
  # GET /use_restrictions/1.xml
  def show
    @use_restriction = UseRestriction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @use_restriction }
    end
  end

  # GET /use_restrictions/new
  # GET /use_restrictions/new.xml
  def new
    @use_restriction = UseRestriction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @use_restriction }
    end
  end

  # GET /use_restrictions/1/edit
  def edit
    @use_restriction = UseRestriction.find(params[:id])
  end

  # POST /use_restrictions
  # POST /use_restrictions.xml
  def create
    @use_restriction = UseRestriction.new(params[:use_restriction])

    respond_to do |format|
      if @use_restriction.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.use_restriction'))
        format.html { redirect_to(@use_restriction) }
        format.xml  { render :xml => @use_restriction, :status => :created, :location => @use_restriction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @use_restriction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /use_restrictions/1
  # PUT /use_restrictions/1.xml
  def update
    @use_restriction = UseRestriction.find(params[:id])

    respond_to do |format|
      if @use_restriction.update_attributes(params[:use_restriction])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.use_restriction'))
        format.html { redirect_to(@use_restriction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @use_restriction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /use_restrictions/1
  # DELETE /use_restrictions/1.xml
  def destroy
    @use_restriction = UseRestriction.find(params[:id])
    @use_restriction.destroy

    respond_to do |format|
      format.html { redirect_to(use_restrictions_url) }
      format.xml  { head :ok }
    end
  end
end
