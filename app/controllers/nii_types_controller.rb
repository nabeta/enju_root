class NiiTypesController < ApplicationController
  load_and_authorize_resource

  # GET /nii_types
  # GET /nii_types.xml
  def index
    @nii_types = NiiType.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nii_types }
    end
  end

  # GET /nii_types/1
  # GET /nii_types/1.xml
  def show
    @nii_type = NiiType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nii_type }
    end
  end

  # GET /nii_types/new
  # GET /nii_types/new.xml
  def new
    @nii_type = NiiType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nii_type }
    end
  end

  # GET /nii_types/1/edit
  def edit
    @nii_type = NiiType.find(params[:id])
  end

  # POST /nii_types
  # POST /nii_types.xml
  def create
    @nii_type = NiiType.new(params[:nii_type])

    respond_to do |format|
      if @nii_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.nii_type'))
        format.html { redirect_to(@nii_type) }
        format.xml  { render :xml => @nii_type, :status => :created, :location => @nii_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nii_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nii_types/1
  # PUT /nii_types/1.xml
  def update
    @nii_type = NiiType.find(params[:id])

    if @nii_type and params[:position]
      @nii_type.insert_at(params[:position])
      redirect_to nii_types_url
      return
    end

    respond_to do |format|
      if @nii_type.update_attributes(params[:nii_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.nii_type'))
        format.html { redirect_to(@nii_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nii_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nii_types/1
  # DELETE /nii_types/1.xml
  def destroy
    @nii_type = NiiType.find(params[:id])
    @nii_type.destroy

    respond_to do |format|
      format.html { redirect_to(nii_types_url) }
      format.xml  { head :ok }
    end
  end
end
