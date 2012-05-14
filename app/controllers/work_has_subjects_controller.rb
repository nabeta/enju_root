class WorkHasSubjectsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_work, :get_subject
  before_filter :get_patron
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  #cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /work_has_subjects
  # GET /work_has_subjects.json
  def index
    if @work
      @work_has_subjects = @work.work_has_subjects.paginate(:page => params[:page])
    elsif @subject
      @work_has_subjects = @subject.work_has_subjects.paginate(:page => params[:page])
    else
      @work_has_subjects = WorkHasSubject.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @work_has_subjects }
    end
  end

  # GET /work_has_subjects/1
  # GET /work_has_subjects/1.json
  def show
    @work_has_subject = WorkHasSubject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @work_has_subject }
    end
  end

  # GET /work_has_subjects/new
  # GET /work_has_subjects/new.json
  def new
    @work_has_subject = WorkHasSubject.new
    @work_has_subject.work = @work
    @work_has_subject.subject = @subject

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @work_has_subject }
    end
  end

  # GET /work_has_subjects/1/edit
  def edit
    @work_has_subject = WorkHasSubject.find(params[:id])
  end

  # POST /work_has_subjects
  # POST /work_has_subjects.json
  def create
    @work_has_subject = WorkHasSubject.new(params[:work_has_subject])
    #begin
    #  klass = params[:work_has_subject][:subjectable_type].to_s.constantize
    #  object = klass.find(params[:work_has_subject][:subjectable_id])
    #  @work_has_subject.subjectable = object
    #rescue
    #  nil
    #end

    respond_to do |format|
      if @work_has_subject.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_has_subject'))
        format.html { redirect_to(@work_has_subject) }
        format.json { render :json => @work_has_subject, :status => :created, :location => @work_has_subject }
      else
        format.html { render :action => "new" }
        format.json { render :json => @work_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_has_subjects/1
  # PUT /work_has_subjects/1.json
  def update
    @work_has_subject = WorkHasSubject.find(params[:id])

    respond_to do |format|
      if @work_has_subject.update_attributes(params[:work_has_subject])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_has_subject'))
        format.html { redirect_to(@work_has_subject) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @work_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_has_subjects/1
  # DELETE /work_has_subjects/1.json
  def destroy
    @work_has_subject = WorkHasSubject.find(params[:id])
    @work_has_subject.destroy

    respond_to do |format|
      case
      when @patron
        format.html { redirect_to(patron_work_has_subjects_url(@patron)) }
        format.json { head :no_content }
      when @work
        format.html { redirect_to(work_work_has_subjects_url(@work)) }
        format.json { head :no_content }
      #when @expression
      #  format.html { redirect_to(expression_work_has_subjects_url(@expression)) }
      #  format.json { head :no_content }
      #when @manifestation
      #  format.html { redirect_to(manifestation_work_has_subjects_url(@manifestation)) }
      #  format.json { head :no_content }
      #when @item
      #  format.html { redirect_to(item_work_has_subjects_url(@item)) }
      #  format.json { head :no_content }
      when @subject
        format.html { redirect_to(subject_work_has_subjects_url(@subject)) }
        format.json { head :no_content }
      else
        format.html { redirect_to(work_has_subjects_url) }
        format.json { head :no_content }
      end
    end
  end
end
