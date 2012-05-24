# -*- encoding: utf-8 -*-
class WorksController < ApplicationController
  load_and_authorize_resource
  before_filter :get_patron, :get_subject, :get_subscription
  before_filter :get_work, :only => :index
  before_filter :get_series_statement, :only => [:index, :new, :edit]
  before_filter :get_work_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_version, :only => [:show]
  #cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /works
  # GET /works.json
  def index
    query = params[:query].to_s.strip
    search = Sunspot.new_search(Work)
    @count = {}
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.build do
        fulltext query
      end
    end

    set_role_query(current_user, search)

    unless params[:mode] == 'add'
      patron = @patron
      subject = @subject
      subscription = @subscription
      work = @work
      work_merge_list = @work_merge_list
      search.build do
        with(:patron_ids).equal_to patron.id if patron
        with(:subject_ids).equal_to subject.id if subject
        with(:subscription_ids).equal_to subscription.id if subscription
        with(:original_work_ids).equal_to work.id if work
        with(:work_merge_list_ids).equal_to work_merge_list.id if work_merge_list
      end
    end

    role = current_user.try(:role) || Role.find('Guest')
    search.build do
      with(:required_role_id).less_than role.id
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Work.per_page)
    @works = search.execute!.results
    @count[:total] = @works.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @works }
      format.atom
    end
  end

  # GET /works/1
  # GET /works/1.json
  def show
    @work = @work.versions.find(@version).item if @version

    if @patron
      created = @work.patrons.find(@patron) rescue nil
      if created.blank?
        redirect_to :controller => 'creates', :action => 'new', :work_id => @work.id, :patron_id => @patron.id
        return
      end
    end
    search = Sunspot.new_search(Subject)
    work = @work
    search.build do
      with(:work_ids).equal_to work.id if work
    end
    page = params[:subject_page] || 1
    search.query.paginate(page.to_i, Subject.per_page)
    @subjects = search.execute!.results

    expression_list_page = params[:expression_list_page] || 1
    manifestation_list_page = params[:manifestation_list_page] || 1
    if params[:expression_list_page] or expression_list_page == 1
      @expressions = Expression.search do
        with(:work_id).equal_to work.id
        paginate :page => expression_list_page, :per_page => Expression.per_page
      end.results
    end
    if params[:manifestation_list_page] or manifestation_list_page == 1
      @manifestations = Manifestation.search do
        with(:work_ids).equal_to work.id
        paginate :page => manifestation_list_page, :per_page => Manifestation.per_page
      end.results
    end

    #@subjects = @work.subjects.paginate(:page => params[:subject_page], :total_entries => @work.work_has_subjects.size)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @work }
      format.js
    end
  end

  # GET /works/new
  def new
    @work = Work.new
    @patron = Patron.find(params[:patron_id]) rescue nil
    if @series_statement
      @work.series_statement = @series_statement
      @work.original_title = @series_statement.original_title
      @work.title_transcription = @series_statement.title_transcription
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @work }
    end
  end

  # GET /works/1/edit
  def edit
    @work.series_statement = @series_statement
  end

  # POST /works
  # POST /works.json
  def create
    @work = Work.new(params[:work])

    respond_to do |format|
      if @work.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work'))
        if @patron
          @patron.works << @work
        end
        format.html { redirect_to @work }
        format.json { render :json => @work, :status => :created, :location => @work }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /works/1
  # PUT /works/1.json
  def update
    respond_to do |format|
      if @work.update_attributes(params[:work])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work'))
        format.html { redirect_to work_url(@work) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.json
  def destroy
    @work.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.work'))
      format.html { redirect_to works_url }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @form_of_works = FormOfWork.all
    @roles = Role.all
  end
end
