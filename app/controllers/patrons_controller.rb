class PatronsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_work, :get_expression, :get_manifestation, :get_item
  before_filter :get_patron_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :store_location
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

    if params[:mode] == 'recent'
      query = "#{query} created_at: [NOW-1MONTH TO NOW]"
    end

    browse = nil
    order = nil
    @count = {}

    if logged_in?
      unless current_user.has_role?('Librarian')
        query += " required_role_id: [* TO 2]"
      end
    else
      query += " required_role_id: 1"
    end

    unless query.blank?
      unless params[:mode] == 'add'
        query.add_query!(@work) if @work
        query.add_query!(@expression) if @expression
        query.add_query!(@manifestation) if @manifestation
        query += " patron_merge_list_ids: #{@patron_merge_list.id}" if @patron_merge_list
      end

      @patrons = Patron.paginate_by_solr(query, :order => order, :page => params[:page], :per_page => @per_page).compact
      @count[:query_result] = @patrons.total_entries
      @patrons = Patron.paginate_by_solr(query, :page => params[:page], :per_page => @per_page, :order => 'updated_at desc').compact
    else
      case
      when @work
        @patrons = @work.patrons.paginate(:page => params[:page])
      when @expression
        @patrons = @expression.patrons.paginate(:page => params[:page])
      when @manifestation
        @patrons = @manifestation.patrons.paginate(:page => params[:page])
      when @patron_merge_list
        @patrons = @patron_merge_list.patrons.paginate(:page => params[:page])
      else
        @patrons = Patron.paginate(:all, :page => params[:page])
      end

    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @patrons }
      format.rss  { render :layout => false }
      format.atom
      format.json
    end
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

    #@involved_manifestations = @patron.involved_manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')
    @works = @patron.works.paginate(:page => params[:work_list_page], :per_page => 10)
    @expressions = @patron.expressions.paginate(:page => params[:expression_list_page], :per_page => 10)
    @manifestations = @patron.manifestations.paginate(:page => params[:manifestation_list_page], :per_page => 10, :order => 'date_of_publication DESC')

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
    @patron = Patron.new
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
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /patrons
  # POST /patrons.xml
  def create
    @patron = Patron.new(params[:patron])

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
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /patrons/1
  # DELETE /patrons/1.xml
  def destroy
    @patron = Patron.find(params[:id])

    if @patron.user
      if @patron.user.has_role?('Librarian')
        unless current_user.has_role?('Administrator')
          access_denied
          return
        end
      end
    end

    @patron.destroy

    respond_to do |format|
      format.html { redirect_to patrons_url }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private

  def get_patron
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
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def prepare_options
    @patron_types = PatronType.find(:all, :order => :position)
    @languages = Language.find(:all, :order => :position)
    @countries = Country.find(:all, :order => :position)
    @roles = Role.find(:all)
  end

end
