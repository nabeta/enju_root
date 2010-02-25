# -*- encoding: utf-8 -*-
class PatronsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user_if_nil
  before_filter :get_work, :get_expression, :get_manifestation, :get_item
  before_filter :get_patron, :only => :index
  before_filter :get_patron_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :store_location
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  
  # GET /patrons
  # GET /patrons.xml
  def index
    #session[:params] = {} unless session[:params]
    #session[:params][:patron] = params
    # 最近追加されたパトロン
    #@query = params[:query] ||= "[* TO *]"
    query = params[:query].to_s.strip
    @query = query.dup
    query = query.gsub('　', ' ')
    order = nil
    @count = {}

    search = Sunspot.new_search(Patron)
    set_role_query(current_user, search)

    if params[:mode] == 'recent'
      query = "#{query} created_at_d: [NOW-1MONTH TO NOW]"
    end
    unless query.blank?
      search.build do
        fulltext query
      end
    end
    unless params[:mode] == 'add'
      user = @user
      work = @work
      expression = @expression
      manifestation = @manifestation
      patron = @patron
      patron_merge_list = @patron_merge_list
      search.build do
        with(:user).equal_to user.login if user
        with(:work_ids).equal_to work.id if work
        with(:expression_ids).equal_to expression.id if expression
        with(:manifestation_ids).equal_to manifestation.id if manifestation
        with(:original_patron_ids).equal_to patron.id if patron
        with(:patron_merge_list_ids).equal_to patron_merge_list.id if patron_merge_list
      end
    end

    role = current_user.try(:highest_role) || Role.find(1)
    search.build do
      with(:required_role_id).less_than role.id+1
    end

    page = params[:page] || 1
    begin
      search.query.paginate(page.to_i, Patron.per_page)
      @patrons = search.execute!.results
    rescue RSolr::RequestError
      @patrons = WillPaginate::Collection.create(1,1,0) do end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @patrons }
      format.rss  { render :layout => false }
      format.atom
      format.json { render :json => @patrons }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to patrons_url
    return
  end

  # GET /patrons/1
  # GET /patrons/1.xml
  def show
    case
    when @work
      @patron = @work.patrons.find(params[:id])
    when @expression
      @patron = @expression.patrons.find(params[:id])
    when @manifestation
      @patron = @manifestation.patrons.find(params[:id])
    when @item
      @patron = @item.patrons.find(params[:id])
    else
      @patron = Patron.find(params[:id])
    end
    @patron = @patron.versions.find(@version).item if @version

    #@involved_manifestations = @patron.involved_manifestations.paginate(:page => params[:page], :order => 'date_of_publication DESC')
    @works = @patron.works.paginate(:page => params[:work_list_page])
    @expressions = @patron.expressions.paginate(:page => params[:expression_list_page])
    @manifestations = @patron.manifestations.paginate(:page => params[:manifestation_list_page], :order => 'date_of_publication DESC')

    canonical_url patron_url(@patron)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @patron }
      format.js {
        render :update do |page|
          page.replace_html 'work', :partial => 'work_list', :locals => {:works => @works} if params[:work_list_page]
          page.replace_html 'expression', :partial => 'expression_list', :locals => {:expressions => @expressions} if params[:expression_list_page]
          page.replace_html 'manifestation', :partial => 'manifestation_list', :locals => {:manifestations => @manifestations} if params[:manifestation_list_page]
        end
      }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /patrons/new
  def new
    unless current_user.has_role?('Librarian')
      unless current_user == @user
        access_denied; return
      end
    end
    @patron = Patron.new
    if @user
      @patron.user = @user
    end
    prepare_options

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron }
    end
  end

  # GET /patrons/1;edit
  def edit
    @patron = Patron.find(params[:id])
    prepare_options
  end

  # POST /patrons
  # POST /patrons.xml
  def create
    @patron = Patron.new(params[:patron])
    if @patron.user_id
      @patron.user = User.find(@patron.user_id) rescue nil
    end
    unless current_user.has_role?('Librarian')
      if @patron.user != current_user
        access_denied; return
      end
    end

    respond_to do |format|
      if @patron.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron'))
        case
        when @work
          @work.patrons << @patron
          format.html { redirect_to patron_work_url(@patron, @work) }
          format.xml  { head :created, :location => patron_work_url(@patron, @work) }
        when @expression
          @expression.patrons << @patron
          format.html { redirect_to patron_expression_url(@patron, @expression) }
          format.xml  { head :created, :location => patron_expression_url(@patron, @expression) }
        when @manifestation
          @manifestation.patrons << @patron
          format.html { redirect_to patron_manifestation_url(@patron, @manifestation) }
          format.xml  { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        when @item
          @item.patrons << @patron
          format.html { redirect_to patron_item_url(@patron, @item) }
          format.xml  { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        else
          format.html { redirect_to(@patron) }
          format.xml  { render :xml => @patron, :status => :created, :location => @patron }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patrons/1
  # PUT /patrons/1.xml
  def update
    @patron = Patron.find(params[:id])

    respond_to do |format|
      if @patron.update_attributes(params[:patron])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron'))
        format.html { redirect_to patron_url(@patron) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patrons/1
  # DELETE /patrons/1.xml
  def destroy
    @patron = Patron.find(params[:id])

    if @patron.user.try(:has_role?, 'Librarian')
      unless current_user.has_role?('Administrator')
        access_denied
        return
      end
    end

    @patron.destroy

    respond_to do |format|
      format.html { redirect_to patrons_url }
      format.xml  { head :ok }
    end
  end

  private

  def prepare_options
    if ENV['RAILS_ENV'] == 'production'
      @countries = Rails.cache.fetch('Country.all'){Country.all}
      @patron_types = Rails.cache.fetch('PatronType.all'){PatronType.all}
      @roles = Rails.cache.fetch('Role.all'){Role.all}
      @languages = Rails.cache.fetch('Language.all'){Language.all}
    else
      @countries = Country.all
      @patron_types = PatronType.all
      @roles = Role.all
      @languages = Language.all
    end
  end

end
