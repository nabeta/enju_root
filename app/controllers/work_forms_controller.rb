class WorkFormsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]

  # GET /work_forms
  # GET /work_forms.xml
  def index
    @work_forms = WorkForm.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_forms }
    end
  end

  # GET /work_forms/1
  # GET /work_forms/1.xml
  def show
    @work_form = WorkForm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_form }
    end
  end

  # GET /work_forms/new
  # GET /work_forms/new.xml
  def new
    @work_form = WorkForm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_form }
    end
  end

  # GET /work_forms/1/edit
  def edit
    @work_form = WorkForm.find(params[:id])
  end

  # POST /work_forms
  # POST /work_forms.xml
  def create
    @work_form = WorkForm.new(params[:work_form])

    respond_to do |format|
      if @work_form.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_form'))
        format.html { redirect_to(@work_form) }
        format.xml  { render :xml => @work_form, :status => :created, :location => @work_form }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_forms/1
  # PUT /work_forms/1.xml
  def update
    @work_form = WorkForm.find(params[:id])

    respond_to do |format|
      if @work_form.update_attributes(params[:work_form])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_form'))
        format.html { redirect_to(@work_form) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_forms/1
  # DELETE /work_forms/1.xml
  def destroy
    @work_form = WorkForm.find(params[:id])
    @work_form.destroy

    respond_to do |format|
      format.html { redirect_to(work_forms_url) }
      format.xml  { head :ok }
    end
  end
end
