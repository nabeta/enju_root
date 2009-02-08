class FamiliesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :only => [:new, :create, :destroy]
  before_filter :get_work, :get_expression, :get_manifestation, :get_item
  before_filter :authorized_content, :only => [:edit, :create, :update, :destroy]
  before_filter :store_location
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  
  # GET /families
  # GET /families.xml
  def index
    session[:params] = {} unless session[:params]
    session[:params][:corporate_body] = params
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
        query += " access_role_id: [* TO 2]"
      end
    else
      query += " access_role_id: 1"
    end

    unless query.blank?

      unless params[:mode] == 'add'
        query += " work_ids: #{@work.id}" if @work
        query += " expression_ids: #{@expression.id}" if @expression
        query += " manifestation_ids: #{@manifestation.id}" if @manifestation
        query += " corporate_body_merge_list_ids: #{@corporate_body_merge_list.id}" if @corporate_body_merge_list
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
      when @corporate_body_merge_list
        @families = @corporate_body_merge_list.families.paginate(:page => params[:page], :per_page => @per_page)
      else
        @families = Family.paginate(:all, :page => params[:page], :per_page => @per_page)
      end

    end

    @startrecord = (params[:page].to_i - 1) * Family.per_page + 1
    @startrecord = 1 if @startrecord < 1

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
    #@corporate_body = Family.find(params[:id])

    unless @corporate_body.check_access_role(current_user)
      access_denied
      return
    end

    @involved_manifestations = @corporate_body.involved_manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')
    @publications = @corporate_body.manifestations.paginate(:page => params[:page], :per_page => 10, :order => 'date_of_publication DESC')

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @corporate_body }
    end
  end

  # GET /families/new
  def new
    @corporate_body = Family.new
    unless @corporate_body.check_access_role(current_user)
      access_denied
      return
    end
    prepare_options
  end

  # GET /families/1;edit
  def edit
    #@corporate_body = Family.find(params[:id])
    unless current_user.has_role?('Librarian')
      unless @corporate_body.check_access_role(current_user)
        access_denied
        return
      end
    end
    unless @corporate_body.check_access_role(current_user)
      access_denied
      return
    end
    prepare_options
  end

  # POST /families
  # POST /families.xml
  def create
    @corporate_body = Family.new(params[:corporate_body])

    respond_to do |format|
      if @corporate_body.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.corporate_body'))
        case
        when @work
          @work.families << @corporate_body
          format.html { redirect_to corporate_body_work_url(@corporate_body, @work) }
          format.xml  { head :created, :location => corporate_body_work_url(@corporate_body, @work) }
        when @expression
          @expression.families << @corporate_body
          format.html { redirect_to corporate_body_expression_url(@corporate_body, @expression) }
          format.xml  { head :created, :location => corporate_body_expression_url(@corporate_body, @expression) }
        when @manifestation
          @manifestation.families << @corporate_body
          format.html { redirect_to corporate_body_manifestation_url(@corporate_body, @manifestation) }
          format.xml  { head :created, :location => corporate_body_manifestation_url(@corporate_body, @manifestation) }
        else
          format.html { redirect_to corporate_body_url(@corporate_body) }
          format.xml  { head :created, :location => corporate_body_url(@corporate_body) }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @corporate_body.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /families/1
  # PUT /families/1.xml
  def update
    #@corporate_body = Family.find(params[:id])
    unless @corporate_body.check_access_role(current_user)
      access_denied
      return
    end

    respond_to do |format|
      if @corporate_body.update_attributes(params[:corporate_body])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.corporate_body'))
        format.html { redirect_to corporate_body_url(@corporate_body) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @corporate_body.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1
  # DELETE /families/1.xml
  def destroy
    #@corporate_body = Family.find(params[:id])
    unless @corporate_body.check_access_role(current_user)
      access_denied
      return
    end

    if @corporate_body.user
      if @corporate_body.user.has_role?('Librarian')
        unless current_user.has_role?('Administrator')
          access_denied
          return
        end
      end
    end

    @corporate_body.destroy

    respond_to do |format|
      format.html { redirect_to families_url }
      format.xml  { head :ok }
    end
  end

  private

  def get_corporate_body
    case
    when @work
      @corporate_body = @work.families.find(params[:id])
    when @expression
      @corporate_body = @expression.families.find(params[:id])
    when @manifestation
      @corporate_body = @manifestation.families.find(params[:id])
    when @item
      @corporate_body = @item.families.find(params[:id])
    else
      @corporate_body = Family.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def authorized_content
    unless current_user.has_role?('Librarian')
      unless @corporate_body.user == current_user
        access_denied
        return
      end
    end
  end

  def prepare_options
    @languages = Language.find(:all, :order => :position)
    @countries = Country.find(:all, :order => :position)
    @roles = Role.find(:all)
  end
end
