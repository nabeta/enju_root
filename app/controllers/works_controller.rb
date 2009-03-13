class WorksController < ApplicationController
  before_filter :has_permission?
  #before_filter :get_parent
  before_filter :get_patron
  before_filter :get_work_merge_list
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /works
  # GET /works.xml
  def index
    query = params[:query].to_s.strip
    unless query.blank?
      @count = {}
      @query = query.dup
      query = query.gsub('　', ' ')
      unless params[:mode] == 'add'
        query.add_query!(@patron) if @patron
        query += " parent_id: #{@parent.id}" if @parent
        query += " work_merge_list_ids: #{@work_merge_list.id}" if @work_merge_list
      end
      @works = Work.paginate_by_solr(query, :facets => {:zeros => true, :fields => [:language_id]}, :page => params[:page]).compact
      @count[:total] = @works.total_entries
    else
      case
      when @patron
        @works = @patron.works.paginate(:page => params[:page], :order => 'works.id')
      when @parent_work
        @works = @parent_work.derived_works.paginate(:page => params[:page], :order => 'works.id')
      when @derived_work
        @works = @derived_work.parent_works.paginate(:page => params[:page], :order => 'works.id')
      when @work_merge_list
        @works = @work_merge_list.works.paginate(:page => params[:page])
      else
        @works = Work.paginate(:all, :page => params[:page], :order => 'works.id')
      end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @works }
      format.atom
    end
  end

  # GET /works/1
  # GET /works/1.xml
  def show
    @work = Work.find(params[:id])
    if @patron
      created = @work.patrons.find(@patron) rescue nil
      if created.blank?
        redirect_to :controller => 'creates', :action => 'new', :work_id => @work.id, :patron_id => @patron.id
        return
      end
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @work }
      format.json { render :json => @work }
    end
  end

  # GET /works/new
  def new
    @work = Work.new
    @patron = Patron.find(params[:patron_id]) rescue nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work }
    end
  end

  # GET /works/1;edit
  def edit
    @work = Work.find(params[:id])
  end

  # POST /works
  # POST /works.xml
  def create
    @work = Work.new(params[:work])

    respond_to do |format|
      if @work.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work'))
        if @patron
          @patron.works << @work
          format.html { redirect_to work_url(@work) }
          format.xml  { render :xml => @work, :status => :created, :location => @work }
        else
          format.html { redirect_to work_patrons_url(@work) }
          format.xml  { render :xml => @work, :status => :created, :location => @work }
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /works/1
  # PUT /works/1.xml
  def update
    @work = Work.find(params[:id])

    respond_to do |format|
      if @work.update_attributes(params[:work])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work'))
        format.html { redirect_to work_url(@work) }
        format.xml  { head :ok }
        format.json { render :json => @work }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
        format.json { render :json => @work, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.xml
  def destroy
    @work = Work.find(params[:id])
    @work.destroy

    respond_to do |format|
      format.html { redirect_to works_url }
      format.xml  { head :ok }
    end
  end

  private
  def get_parent
    @parent = Work.find(params[:parent_id]) if params[:parent_id]
  rescue
    nil
  end

end
