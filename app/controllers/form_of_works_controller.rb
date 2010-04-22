class FormOfWorksController < ApplicationController
  load_and_authorize_resource

  # GET /form_of_works
  # GET /form_of_works.xml
  def index
    @form_of_works = FormOfWork.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @form_of_works }
    end
  end

  # GET /form_of_works/1
  # GET /form_of_works/1.xml
  def show
    @form_of_work = FormOfWork.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form_of_work }
    end
  end

  # GET /form_of_works/new
  # GET /form_of_works/new.xml
  def new
    @form_of_work = FormOfWork.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form_of_work }
    end
  end

  # GET /form_of_works/1/edit
  def edit
    @form_of_work = FormOfWork.find(params[:id])
  end

  # POST /form_of_works
  # POST /form_of_works.xml
  def create
    @form_of_work = FormOfWork.new(params[:form_of_work])

    respond_to do |format|
      if @form_of_work.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.form_of_work'))
        format.html { redirect_to(@form_of_work) }
        format.xml  { render :xml => @form_of_work, :status => :created, :location => @form_of_work }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @form_of_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /form_of_works/1
  # PUT /form_of_works/1.xml
  def update
    @form_of_work = FormOfWork.find(params[:id])

    respond_to do |format|
      if @form_of_work.update_attributes(params[:form_of_work])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.form_of_work'))
        format.html { redirect_to(@form_of_work) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form_of_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /form_of_works/1
  # DELETE /form_of_works/1.xml
  def destroy
    @form_of_work = FormOfWork.find(params[:id])
    @form_of_work.destroy

    respond_to do |format|
      format.html { redirect_to(form_of_works_url) }
      format.xml  { head :ok }
    end
  end
end
