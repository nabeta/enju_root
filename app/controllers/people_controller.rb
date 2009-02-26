class PeopleController < ApplicationController
  before_filter :has_permission?
  before_filter :get_work, :get_expression, :get_manifestation, :get_item
  before_filter :store_location
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  
  # GET /people
  # GET /people.xml
  def index
    session[:params] = {} unless session[:params]
    session[:params][:person] = params
    # 最近追加されたパトロン
    if params[:recent]
      @query = "[* TO *] created_at:[#{1.month.ago.utc.iso8601} TO #{Time.zone.now.iso8601}]"
    elsif params[:query]
      #@query = params[:query] ||= "[* TO *]"
      @query = params[:query].to_s.strip
    end
    browse = nil
    order = nil
    @count = {}

    query = @query.to_s.strip
    if logged_in?
      unless current_user.has_role?('Librarian')
        query += " required_role_id: [* TO 2]"
      end
    else
      query += " required_role_id: 1"
    end

    unless query.blank?

      unless params[:mode] == 'add'
        query.add_query!(@work)
        query.add_query!(@expression)
        query.add_query!(@manifestation)
        query += " person_merge_list_ids: #{@person_merge_list.id}" if @person_merge_list
      end

      @people = Person.paginate_by_solr(query, :order => order, :page => params[:page], :per_page => @per_page).compact
      @count[:query_result] = @people.total_entries
      @people = Person.paginate_by_solr(query, :page => params[:page], :per_page => @per_page, :order => 'updated_at desc').compact
    else
      case
      when @work
        @people = @work.people.paginate(:page => params[:page], :per_page => @per_page)
      when @expression
        @people = @expression.people.paginate(:page => params[:page], :per_page => @per_page)
      when @manifestation
        @people = @manifestation.people.paginate(:page => params[:page], :per_page => @per_page)
      when @person_merge_list
        @people = @person_merge_list.people.paginate(:page => params[:page], :per_page => @per_page)
      else
        @people = Person.paginate(:all, :page => params[:page], :per_page => @per_page)
      end

    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @people }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    unless @person.check_required_role(current_user)
      access_denied
      return
    end

    #@involved_manifestations = @person.involved_manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')
    #@publications = @person.manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  def new
    prepare_options
    @person = Person.new
    unless @person.check_required_role(current_user)
      access_denied
      return
    end
  end

  # GET /people/1;edit
  def edit
    prepare_options
    @person = Person.find(params[:id])
    unless current_user.has_role?('Librarian')
      unless @person.check_required_role(current_user)
        access_denied
        return
      end
    end
    unless @person.check_required_role(current_user)
      access_denied
      return
    end
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.person'))
        case
        when @work
          @work.people << @person
          format.html { redirect_to person_work_url(@person, @work) }
          format.xml  { head :created, :location => person_work_url(@person, @work) }
        when @expression
          @expression.people << @person
          format.html { redirect_to person_expression_url(@person, @expression) }
          format.xml  { head :created, :location => person_expression_url(@person, @expression) }
        when @manifestation
          @manifestation.people << @person
          format.html { redirect_to person_manifestation_url(@person, @manifestation) }
          format.xml  { head :created, :location => person_manifestation_url(@person, @manifestation) }
        else
          format.html { redirect_to person_url(@person) }
          format.xml  { head :created, :location => person_url(@person) }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])
    unless @person.check_required_role(current_user)
      access_denied
      return
    end

    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.person'))
        format.html { redirect_to person_url(@person) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    unless @person.check_required_role(current_user)
      access_denied
      return
    end

    if @person.user
      if @person.user.has_role?('Librarian')
        unless current_user.has_role?('Administrator')
          access_denied
          return
        end
      end
    end

    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.xml  { head :ok }
    end
  end

  private

  def get_person
    case
    when @work
      @person = @work.people.find(params[:id])
    when @expression
      @person = @expression.people.find(params[:id])
    when @manifestation
      @person = @manifestation.people.find(params[:id])
    when @item
      @person = @item.people.find(params[:id])
    else
      @person = Person.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def prepare_options
    @languages = Language.find(:all, :order => :position)
    @countries = Country.find(:all, :order => :position)
    @roles = Role.find(:all)
  end
end
