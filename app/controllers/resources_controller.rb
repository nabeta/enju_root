class ResourcesController < ApplicationController
  load_and_authorize_resource
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  include OaiController

  # GET /resources
  # GET /resources.xml
  def index
    @seconds = Benchmark.realtime do
      @oai = check_oai_params(params)
      next if @oai[:need_not_to_search]
      if params[:format] == 'oai'
        # OAI-PMHのデフォルトの件数
        per_page = 200
        if params[:resumptionToken]
          if current_token = get_resumption_token(params[:resumptionToken])
            page = (current_token[:cursor].to_i + per_page).div(per_page) + 1
          else
            @oai[:errors] << "badResumptionToken"
          end
        end
        page ||= 1
      end

      from_and_until_times = set_from_and_until(Resource, params[:from], params[:until])
      from_time = @from_time = from_and_until_times[:from]
      until_time = @until_time = from_and_until_times[:until]

      if params[:format] == 'oai'
        if params[:verb] == 'GetRecord' and params[:identifier]
          begin
            resource = Resource.find_by_oai_identifier(params[:identifier])
          rescue ActiveRecord::RecordNotFound
            @oai[:errors] << "idDoesNotExist"
            render :template => 'resources/index.oai.builder'
            return
          end
          @resource = resource
          render :template => 'resources/show.oai.builder'
          return
        end
      end

      page ||= params[:page] || 1

      case params[:approved]
      when 'true'
        if current_user
          if current_user.has_role?('Administrator')
            @resources = Resource.approved(@from_time, @until_time).not_deleted.paginate(:page => page)
          else
            access_denied; return
          end
        else
          redirect_to new_user_session_url; return
        end
      when 'false'
        if current_user
          if current_user.has_role?('Administrator')
            @resources = Resource.not_approved(@from_time, @until_time).not_deleted.paginate(:page => page)
          else
            access_denied; return
          end
        else
          redirect_to new_user_session_url; return
        end
      else
        if Resource.respond_to?(:search)
          query = params[:query]
          @query = query
          published = true unless current_user.try(:has_role?, 'Administrator')
          search = Sunspot.new_search(Resource)
          deleted = true if params[:format] == 'oai'
          search.build do
            fulltext query
            with(:state).equal_to 'published' if published
            with(:updated_at).greater_than from_time if from_time
            with(:updated_at).less_than until_time if until_time
            with(:deleted_at).equal_to nil if deleted
          end
          search.query.paginate(page.to_i, Resource.per_page)
          @resources = search.execute!.results
        else
          if current_user.try(:has_role?, 'Administrator')
            if params[:format] == 'oai'
              @resources = Resource.all_record(@from_time, @until_time).paginate(:page => page)
            else
              @resources = Resource.all_record(@from_time, @until_time).not_deleted.paginate(:page => page)
            end
          else
            if params[:format] == 'oai'
              @resources = Resource.published(@from_time, @until_time).paginate(:page => page)
            else
              @resources = Resource.published(@from_time, @until_time).not_deleted.paginate(:page => page)
            end
          end
        end
      end

      if params[:format] == 'oai'
        unless @resources.empty?
          set_resumption_token(params[:resumptionToken], @from_time || Resource.last.updated_at, @until_time || Resource.first.updated_at)
        else
          @oai[:errors] << 'noRecordsMatch'
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resources }
      format.oai  {
        case params[:verb]
        when 'Identify'
          render :template => 'resources/identify'
        when 'ListMetadataFormats'
          render :template => 'resources/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.all
          render :template => 'resources/list_sets'
        when 'ListIdentifiers'
          render :template => 'resources/list_identifiers'
        when 'ListRecords'
          render :template => 'resources/list_records'
        end
      }
    end
  end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    @resource = Resource.find(params[:id])
    if check_deleted?
      unless current_user.try(:has_role?, 'Librarian')
        not_found
      end
    end
    unless current_user.try(:has_role?, 'Librarian')
      unless @resource.last_published
        not_found
      end
      @resource = @resource.last_published
      authorize! :show, @resource
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource }
      format.oai
    end
  end

  # GET /resources/new
  # GET /resources/new.xml
  def new
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
    if check_deleted?
      not_found; return
    end
  end

  # POST /resources
  # POST /resources.xml
  def create
    @resource = Resource.new(params[:resource])

    respond_to do |format|
      if @resource.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource'))
        format.html { redirect_to(@resource) }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])
    if check_deleted?
      not_found; return
    end
    case params[:commit]
    when t('resource.approve')
      @resource.approve = "1"
    when t('resource.publish')
      @resource.publish = "1"
    end

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.resource'))
        format.html { redirect_to(@resource) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    if check_deleted?
      not_found; return
    end
    #@resource.destroy
    @resource.deleted_at = Time.zone.now

    respond_to do |format|
      if @resource.save
        format.html { redirect_to(resources_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  def approve_selected
    if current_user
      unless current_user.has_role?('Librarian')
        access_denied
      end
    else
      redirect_to new_user_session_url
      return
    end
    respond_to do |format|
      if params[:to_approved].present?
        resources = params[:to_approved].map {|r| Resource.find_by_id(r)}
      elsif params[:approve] == 'all_resources'
        resources = Resource.where(:state => 'not_approved')
      end
      if resources.present?
        resources.each do |resource|
          resource.approve = '1'
          resource.save
        end
        flash[:notice] = t('resource.resources_were_approved')
        format.html { redirect_to resources_url(:approved => "false") }
      else
        flash[:notice] = t('resource.select_resources')
        format.html { redirect_to resources_url(:approved => "false") }
      end
    end
  end

  def publish_selected
    if current_user
      unless current_user.has_role?('Librarian')
        access_denied
      end
    else
      redirect_to new_user_session_url
      return
    end
    respond_to do |format|
      if params[:to_published].present?
        resources = params[:to_published].map {|r| Resource.find_by_id(r)}
      elsif params[:publish] == 'all_resources'
        resources = Resource.where(:state => 'approved')
      end
      if resources.present?
        resources.each do |resource|
          resource.publish = '1'
          resource.save
        end
        flash[:notice] = t('resource.resources_were_published')
        format.html { redirect_to resources_url(:approved => "true") }
      else
        flash[:notice] = t('resource.select_resources')
        format.html { redirect_to resources_url(:approved => "true") }
      end
    end
  end

  private
  def check_deleted?
    true if @resource.deleted_at
  end
end
