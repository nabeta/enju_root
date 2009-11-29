class AdvertisementsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /advertisements
  # GET /advertisements.xml
  def index
    @advertisements = Advertisement.paginate(:all, :page => params[:page], :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @advertisements }
    end
  end

  # GET /advertisements/1
  # GET /advertisements/1.xml
  def show
    @advertisement = Advertisement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @advertisement }
    end
  end

  # GET /advertisements/new
  # GET /advertisements/new.xml
  def new
    @advertisement = Advertisement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @advertisement }
    end
  end

  # GET /advertisements/1/edit
  def edit
    @advertisement = Advertisement.find(params[:id])
  end

  # POST /advertisements
  # POST /advertisements.xml
  def create
    @advertisement = Advertisement.new(params[:advertisement])

    respond_to do |format|
      if @advertisement.save
        # TODO: パトロンからの受付
        @advertisement.patrons << current_user.patron
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.advertisement'))
        format.html { redirect_to(@advertisement) }
        format.xml  { render :xml => @advertisement, :status => :created, :location => @advertisement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /advertisements/1
  # PUT /advertisements/1.xml
  def update
    @advertisement = Advertisement.find(params[:id])

    respond_to do |format|
      if @advertisement.update_attributes(params[:advertisement])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.advertisement'))
        format.html { redirect_to(@advertisement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /advertisements/1
  # DELETE /advertisements/1.xml
  def destroy
    @advertisement = Advertisement.find(params[:id])
    @advertisement.destroy

    respond_to do |format|
      format.html { redirect_to(advertisements_url) }
      format.xml  { head :ok }
    end
  end
end
