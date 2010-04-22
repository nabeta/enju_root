class SubjectHeadingTypesController < ApplicationController
  before_filter :check_client_ip_address, :get_subject
  load_and_authorize_resource

  # GET /subject_heading_types
  # GET /subject_heading_types.xml
  def index
    if @subject
      @subject_heading_types = @subject.subject_heading_types
    else
      @subject_heading_types = SubjectHeadingType.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subject_heading_types }
    end
  end

  # GET /subject_heading_types/1
  # GET /subject_heading_types/1.xml
  def show
    @subject_heading_type = SubjectHeadingType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject_heading_type }
    end
  end

  # GET /subject_heading_types/new
  # GET /subject_heading_types/new.xml
  def new
    @subject_heading_type = SubjectHeadingType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject_heading_type }
    end
  end

  # GET /subject_heading_types/1/edit
  def edit
    @subject_heading_type = SubjectHeadingType.find(params[:id])
  end

  # POST /subject_heading_types
  # POST /subject_heading_types.xml
  def create
    @subject_heading_type = SubjectHeadingType.new(params[:subject_heading_type])

    respond_to do |format|
      if @subject_heading_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.subject_heading_type'))
        format.html { redirect_to(@subject_heading_type) }
        format.xml  { render :xml => @subject_heading_type, :status => :created, :location => @subject_heading_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject_heading_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subject_heading_types/1
  # PUT /subject_heading_types/1.xml
  def update
    @subject_heading_type = SubjectHeadingType.find(params[:id])

    if @subject_heading_type and params[:position]
      @subject_heading_type.insert_at(params[:position])
      redirect_to subject_heading_types_url
      return
    end

    respond_to do |format|
      if @subject_heading_type.update_attributes(params[:subject_heading_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.subject_heading_type'))
        format.html { redirect_to(@subject_heading_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject_heading_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_heading_types/1
  # DELETE /subject_heading_types/1.xml
  def destroy
    @subject_heading_type = SubjectHeadingType.find(params[:id])
    @subject_heading_type.destroy

    respond_to do |format|
      format.html { redirect_to(subject_heading_types_url) }
      format.xml  { head :ok }
    end
  end
end
