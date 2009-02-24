class FamiliesController < ApplicationController
  before_filter :has_permission?
  before_filter :get_work, :get_expression, :get_manifestation, :get_item
  before_filter :store_location
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  
  # GET /families
  # GET /families.xml
  def index
    session[:params] = {} unless session[:params]
    session[:params][:family] = params
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
        query += " work_ids: #{@work.id}" if @work
        query += " expression_ids: #{@expression.id}" if @expression
        query += " manifestation_ids: #{@manifestation.id}" if @manifestation
        query += " family_merge_list_ids: #{@family_merge_list.id}" if @family_merge_list
      end

      @families = Family.paginate_by_solr(query, :order => order, :page => params[:page], :per_page => @per_page).compact
      @count[:query_result] = @families.total_entries
      @families = Family.paginate_by_solr(query, :page => params[:page], :per_page => @per_page, :order => 'updated_at desc').compact
    else
      case
      when @work
        @families = @work.families.paginate(:page => params[:page], :per_page => @per_page)
      when @expression
        @families = @expression.families.paginate(:page => params[:page], :per_page => @per_page)
      when @manifestation
        @families = @manifestation.families.paginate(:page => params[:page], :per_page => @per_page)
      when @family_merge_list
        @families = @family_merge_list.families.paginate(:page => params[:page], :per_page => @per_page)
      else
        @families = Family.paginate(:all, :page => params[:page], :per_page => @per_page)
      end

    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @families }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /families/1
  # GET /families/1.xml
  def show
    @family = Family.find(params[:id])

    unless @family.check_required_role(current_user)
      access_denied
      return
    end

    #@involved_manifestations = @family.involved_manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')
    #@publications = @family.manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @family }
    end
  end

  # GET /families/new
  def new
    prepare_options
    @family = Family.new
    unless @family.check_required_role(current_user)
      access_denied
      return
    end
  end

  # GET /families/1;edit
  def edit
    prepare_options
    @family = Family.find(params[:id])
    unless current_user.has_role?('Librarian')
      unless @family.check_required_role(current_user)
        access_denied
        return
      end
    end
    unless @family.check_required_role(current_user)
      access_denied
      return
    end
  end

  # POST /families
  # POST /families.xml
  def create
    @family = Family.new(params[:family])

    respond_to do |format|
      if @family.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.family'))
        case
        when @work
          @work.families << @family
          format.html { redirect_to family_work_url(@family, @work) }
          format.xml  { head :created, :location => family_work_url(@family, @work) }
        when @expression
          @expression.families << @family
          format.html { redirect_to family_expression_url(@family, @expression) }
          format.xml  { head :created, :location => family_expression_url(@family, @expression) }
        when @manifestation
          @manifestation.families << @family
          format.html { redirect_to family_manifestation_url(@family, @manifestation) }
          format.xml  { head :created, :location => family_manifestation_url(@family, @manifestation) }
        else
          format.html { redirect_to family_url(@family) }
          format.xml  { head :created, :location => family_url(@family) }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /families/1
  # PUT /families/1.xml
  def update
    @family = Family.find(params[:id])
    unless @family.check_required_role(current_user)
      access_denied
      return
    end

    respond_to do |format|
      if @family.update_attributes(params[:family])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.family'))
        format.html { redirect_to family_url(@family) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1
  # DELETE /families/1.xml
  def destroy
    @family = Family.find(params[:id])
    unless @family.check_required_role(current_user)
      access_denied
      return
    end

    if @family.user
      if @family.user.has_role?('Librarian')
        unless current_user.has_role?('Administrator')
          access_denied
          return
        end
      end
    end

    @family.destroy

    respond_to do |format|
      format.html { redirect_to families_url }
      format.xml  { head :ok }
    end
  end

  private

  def get_family
    case
    when @work
      @family = @work.families.find(params[:id])
    when @expression
      @family = @expression.families.find(params[:id])
    when @manifestation
      @family = @manifestation.families.find(params[:id])
    when @item
      @family = @item.families.find(params[:id])
    else
      @family = Family.find(params[:id])
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
