class ManifestationFormsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]
  #require_role 'Librarian', :only => [:index, :show]

  # GET /manifestation_forms
  # GET /manifestation_forms.xml
  def index
    @manifestation_forms = ManifestationForm.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @manifestation_forms.to_xml }
    end
  end

  # GET /manifestation_forms/1
  # GET /manifestation_forms/1.xml
  def show
    @manifestation_form = ManifestationForm.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @manifestation_form.to_xml }
    end
  end

  # GET /manifestation_forms/new
  def new
    @manifestation_form = ManifestationForm.new
  end

  # GET /manifestation_forms/1;edit
  def edit
    @manifestation_form = ManifestationForm.find(params[:id])
  end

  # POST /manifestation_forms
  # POST /manifestation_forms.xml
  def create
    @manifestation_form = ManifestationForm.new(params[:manifestation_form])

    respond_to do |format|
      if @manifestation_form.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_form'))
        format.html { redirect_to manifestation_form_url(@manifestation_form) }
        format.xml  { head :created, :location => manifestation_form_url(@manifestation_form) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation_form.errors.to_xml }
      end
    end
  end

  # PUT /manifestation_forms/1
  # PUT /manifestation_forms/1.xml
  def update
    @manifestation_form = ManifestationForm.find(params[:id])

    respond_to do |format|
      if @manifestation_form.update_attributes(params[:manifestation_form])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.manifestation_form'))
        format.html { redirect_to manifestation_form_url(@manifestation_form) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation_form.errors.to_xml }
      end
    end
  end

  # DELETE /manifestation_forms/1
  # DELETE /manifestation_forms/1.xml
  def destroy
    @manifestation_form = ManifestationForm.find(params[:id])
    @manifestation_form.destroy

    respond_to do |format|
      format.html { redirect_to manifestation_forms_url }
      format.xml  { head :ok }
    end
  end
end
