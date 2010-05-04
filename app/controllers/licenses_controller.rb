class LicensesController < ApplicationController
  load_and_authorize_resource

  # GET /licenses
  # GET /licenses.xml
  def index
    @licenses = License.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @licenses }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.xml
  def show
    @license = License.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @license }
    end
  end

  # GET /licenses/new
  # GET /licenses/new.xml
  def new
    @license = License.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @license }
    end
  end

  # GET /licenses/1/edit
  def edit
    @license = License.find(params[:id])
  end

  # POST /licenses
  # POST /licenses.xml
  def create
    @license = License.new(params[:license])

    respond_to do |format|
      if @license.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.license'))
        format.html { redirect_to(@license) }
        format.xml  { render :xml => @license, :status => :created, :location => @license }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @license.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /licenses/1
  # PUT /licenses/1.xml
  def update
    @license = License.find(params[:id])

    if @license and params[:position]
      @license.insert_at(params[:position])
      redirect_to licenses_url
      return
    end

    respond_to do |format|
      if @license.update_attributes(params[:license])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.license'))
        format.html { redirect_to(@license) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @license.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /licenses/1
  # DELETE /licenses/1.xml
  def destroy
    @license = License.find(params[:id])
    @license.destroy

    respond_to do |format|
      format.html { redirect_to(licenses_url) }
      format.xml  { head :ok }
    end
  end
end
