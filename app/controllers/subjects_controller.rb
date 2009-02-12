class SubjectsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]
  before_filter :get_manifestation
  before_filter :get_classification
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /subjects
  # GET /subjects.xml
  def index
    @query = params[:query].to_s.strip
    unless @query.blank?
      query = @query
      unless params[:mode] == 'add'
        query += " manifestation_ids: #{@manifestation.id}" if @manifestation
        query += " classification_ids: #{@classification.id}" if @classification
      end
      @subjects = Subject.paginate_by_solr(query, :page => params[:page], :per_page => @per_page).compact
    else
      case
      when @manifestation
      #@subjects = Subject.find(:all)
        @subjects = @manifestation.subjects.paginate(:page => params[:page], :per_page => @per_page, :order => 'subjects.id')
      when @classification
        @subjects = @classification.subjects.paginate(:page => params[:page], :per_page => @per_page, :order => 'subjects.id')
      else
        @subjects = Subject.paginate(:all, :page => params[:page], :per_page => @per_page, :order => 'subjects.id')
      end
    end
    session[:params] = {} unless session[:params]
    session[:params][:subject] = params

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @subjects.to_xml }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    if params[:term]
      subject = Subject.find(:first, :conditions => {:term => params[:term]})
      redirected_to subject
      return
    end

    @subject = Subject.find(params[:id])

    if @manifestation
      subjected = @subject.manifestations.find(@manifestation) rescue nil
      if subjected.blank?
        redirect_to new_manifestation_resource_has_subject_url(@manifestation, :subject_id => @subject.term)
        return
      end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @subject.to_xml }
    end
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1;edit
  def edit
    if @manifestation
      @subject = @manifestation.subjects.find(params[:id])
    else
      @subject = Subject.find(params[:id])
    end
  end

  # POST /subjects
  # POST /subjects.xml
  def create
    if @manifestation
      @subject = @manifestation.subjects.new(params[:subject])
    else
      @subject = Subject.new(params[:subject])
    end

    respond_to do |format|
      if @subject.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.subject'))
        format.html { redirect_to subject_url(@subject) }
        format.xml  { head :created, :location => subject_url(@subject) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors.to_xml }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.xml
  def update
    if @manifestation
      @subject = @manifestation.subjects.find(params[:id])
    else
      @subject = Subject.find(params[:id])
    end

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.subject'))
        format.html { redirect_to subject_url(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors.to_xml }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.xml
  def destroy
    if @manifestation
      @subject = @manifestation.subjects.find(params[:id])
    else
      @subject = Subject.find(params[:id])
    end
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to subjects_url }
      format.xml  { head :ok }
    end
  end

end
