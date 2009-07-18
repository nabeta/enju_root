class ResourceHasSubjectsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_subject
  before_filter :get_patron
  before_filter :get_work
  #before_filter :get_expression
  #before_filter :get_manifestation
  #before_filter :get_item
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /resource_has_subjects
  # GET /resource_has_subjects.xml
  def index
    if @work
      @resource_has_subjects = @work.resource_has_subjects.paginate(:all, :page => params[:page])
    elsif @subject
      @resource_has_subjects = @subject.resource_has_subjects.paginate(:all, :page => params[:page])
    else
      @resource_has_subjects = ResourceHasSubject.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resource_has_subjects }
    end
  end

  # GET /resource_has_subjects/1
  # GET /resource_has_subjects/1.xml
  def show
    @resource_has_subject = ResourceHasSubject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource_has_subject }
    end
  end

  # GET /resource_has_subjects/new
  # GET /resource_has_subjects/new.xml
  def new
    @resource_has_subject = ResourceHasSubject.new
    @resource_has_subject.work = @work
    @resource_has_subject.subject = @subject

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource_has_subject }
    end
  end

  # GET /resource_has_subjects/1/edit
  def edit
    @resource_has_subject = ResourceHasSubject.find(params[:id])
  end

  # POST /resource_has_subjects
  # POST /resource_has_subjects.xml
  def create
    @resource_has_subject = ResourceHasSubject.new(params[:resource_has_subject])
    #begin
    #  klass = params[:resource_has_subject][:subjectable_type].to_s.constantize
    #  object = klass.find(params[:resource_has_subject][:subjectable_id])
    #  @resource_has_subject.subjectable = object
    #rescue
    #  nil
    #end

    respond_to do |format|
      if @resource_has_subject.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource_has_subject'))
        format.html { redirect_to(@resource_has_subject) }
        format.xml  { render :xml => @resource_has_subject, :status => :created, :location => @resource_has_subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resource_has_subjects/1
  # PUT /resource_has_subjects/1.xml
  def update
    @resource_has_subject = ResourceHasSubject.find(params[:id])

    respond_to do |format|
      if @resource_has_subject.update_attributes(params[:resource_has_subject])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.resource_has_subject'))
        format.html { redirect_to(@resource_has_subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_has_subjects/1
  # DELETE /resource_has_subjects/1.xml
  def destroy
    @resource_has_subject = ResourceHasSubject.find(params[:id])
    @resource_has_subject.destroy

    respond_to do |format|
      case
      when @patron
        format.html { redirect_to(patron_resource_has_subjects_url(@patron)) }
        format.xml  { head :ok }
      when @work
        format.html { redirect_to(work_resource_has_subjects_url(@work)) }
        format.xml  { head :ok }
      #when @expression
      #  format.html { redirect_to(expression_resource_has_subjects_url(@expression)) }
      #  format.xml  { head :ok }
      #when @manifestation
      #  format.html { redirect_to(manifestation_resource_has_subjects_url(@manifestation)) }
      #  format.xml  { head :ok }
      #when @item
      #  format.html { redirect_to(item_resource_has_subjects_url(@item)) }
      #  format.xml  { head :ok }
      when @subject
        format.html { redirect_to(subject_resource_has_subjects_url(@subject)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(resource_has_subjects_url) }
        format.xml  { head :ok }
      end
    end
  end
end
