# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  before_filter :has_permission?, :except => :show
  #before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_expression
  before_filter :get_manifestation, :only => :index
  before_filter :get_series_statement, :only => [:index, :new, :edit]
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_libraries, :only => :index
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  #include WorldcatController

  # GET /manifestations
  # GET /manifestations.xml
  def index
    @seconds = Benchmark.realtime do
      @numdocs = Manifestation.cached_numdocs

	 if logged_in?
	      @user = current_user if @user.nil?
	    end

      session[:manifestation_ids] = [] unless session[:manifestation_ids]
      session[:params] = {} unless session[:params]
      session[:params][:manifestation] = params.merge(:view => nil)
      if params[:reservable] == "true"
        @reservable = "true"
      end

      if params[:format] == 'csv'
        per_page = 65534
      end

      manifestations = {}
      @count = {}
      query = ""
      sort = {}

       #TODO: 受け入れ形式を整理する。
      case "#{params[:format]}:#{params[:api]}"
      when /\Asru:\Z/io
        if params[:operation] == 'searchRetrieve'
          @sru = Sru.new(params)
          query = @sru.cql.to_sunspot
          sort = @sru.sort_by
        else
          render :template => 'manifestations/index.explain.xml', :layout => false
          return
        end
      when /\A:openurl\Z/io
        @openurl = Openurl.new(params)
        @manifestations = @openurl.search
        query = @openurl.query_text
      else
        query = make_query(params[:query], params)
        sort = set_search_result_order(params[:sort_by], params[:order])
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      total_query = @query.dup
      #if total_query.blank?
      #  @count[:total] = 0
      #else
      @count[:total] = get_total_count(total_query)
      #end
      #total_query = query.dup
      #if total_query.blank?
      #  @count[:total] = 0
      #else
      #  count = Sunspot.new_search(Manifestation)
      #  count.query.keywords = total_query
      #  @count[:total] = count.execute!.total
      #end

      search = Sunspot.new_search(Manifestation)
      search = make_internal_query(search)
      role = current_user.try(:highest_role) || Role.find(1)
      search.build do
        order_by sort[:sort_by], sort[:order]
        with(:required_role_id).less_than role.id
      end

      unless query.blank?
        search.build do
          fulltext query
        end
        manifestation_ids = Manifestation.search_ids do
          fulltext query
          order_by sort[:sort_by], sort[:order]
          # TODO: ヒット件数の上限をセットする
          paginate :page => 1, :per_page => 1000 #Manifestation.cached_numdocs
          with(:required_role_id).less_than role.id
        end
      end

      if ["all_facet", "carrier_type_facet", "language_facet", "library_facet", "subject_facet"].index(params[:view])
        prepare_options
        render_facet(search)
        return
      end

      if params[:view] == "tag_cloud"
        if manifestation_ids
          bookmark_ids = Bookmark.all(:select => :id, :conditions => {:manifestation_id => manifestation_ids}).collect(&:id)
          @tags = Tag.bookmarked(bookmark_ids)
        else
          @tags = []
        end
        render :partial => 'tag_cloud'
        return
      end

      page = params[:page] || 1
      unless query.blank?
        #paginated_manifestation_ids = WillPaginate::Collection.create(page, Manifestation.per_page, manifestation_ids.size) do |pager| pager.replace(manifestation_ids) end
        #@manifestations = Manifestation.paginate(:all, :conditions => {:id => paginated_manifestation_ids}, :page => page, :per_page => Manifestation.per_page)
        if params[:format] == 'sru'
          search.query.start_record(params[:startRecord] || 1, params[:maximumRecord] || 200)
        else
          search.query.paginate(page.to_i, per_page || Manifestation.per_page)
        end
        @manifestations = search.execute!.results
        @count[:query_result] = @manifestations.total_entries
      else
        @manifestations = WillPaginate::Collection.create(1,1,0) do end
        @count[:query_result] = 0
      end

      @search_engines = SearchEngine.all

      if @manifestations
        session[:manifestation_ids] = manifestation_ids
      else
        session[:manifestation_ids] = nil
      end

      # TODO: 検索結果が少ない場合にも表示させる
      if manifestation_ids.blank?
        if query.respond_to?(:suggest_tags)
          @suggested_tag = query.suggest_tags.first
        end
      end
      save_search_history(query, @manifestations.offset, @count[:query_result], current_user.try(:login))
    end

    #@opensearch_result = Manifestation.search_cinii(@query, 'rss')
    store_location # before_filter ではファセット検索のURLを記憶してしまう

    respond_to do |format|
      format.html
      format.xml  {
        if params[:oai]
          render :action => 'oai-pmh', :layout => false
        else
          render :layout => false
        end
      }
      format.sru  { render :layout => false }
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.atom
      format.json { render :json => @manifestations }
      format.js {
        render :update do |page|
          page.replace_html 'worldcat_list', :partial => 'worldcat' if params[:worldcat_page]
        end
      }
      format.pdf {
        prawnto :prawn => {
          :page_layout => :landscape,
          :page_size => "A4"},
        :inline => true
      }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to manifestations_url
    return
  rescue QueryError
    render :template => 'manifestations/error.xml', :layout => false
    return
  end

  # GET /manifestations/1
  # GET /manifestations/1.xml
  def show
    if params[:api] or params[:mode] == 'generate_cache'
      unless my_networks?
        access_denied; return
      end
    end
    if params[:isbn]
      if @manifestation = Manifestation.find_by_isbn(params[:isbn])
        redirect_to @manifestation
        return
      else
        raise ActiveRecord::RecordNotFound if @manifestation.nil?
      end
    else
      @manifestation = Manifestation.find(params[:id])
    end
    @manifestation = @manifestation.versions.find(@version).item if @version
    unless @manifestation.is_readable_by(current_user)
      access_denied; return
    end

    case params[:mode]
    when 'send_email'
      if logged_in?
        Notifier.deliver_manifestation_info(current_user, @manifestation)
        flash[:notice] = t('page.sent_email')
        redirect_to manifestation_url(@manifestation)
        return
      end
    when 'generate_cache'
      check_client_ip_address
      return
    end

    return if render_mode(params[:mode])

    @reserved_count = Reserve.waiting.count(:all, :conditions => {:manifestation_id => @manifestation, :checked_out_at => nil})
    @reserve = current_user.reserves.first(:conditions => {:manifestation_id => @manifestation}) if logged_in?

    if @manifestation.respond_to?(:worldcat_record)
      #@worldcat_record = Rails.cache.fetch("worldcat_record_#{@manifestation.id}"){@manifestation.worldcat_record}
      @worldcat_record = @manifestation.worldcat_record
    end
    if @manifestation.respond_to?(:xisbn_manifestations)
      if params[:xisbn_page]
        xisbn_page = params[:xisbn_page].to_i
      else
        xisbn_page = 1
      end
      #@xisbn_manifestations = Rails.cache.fetch("xisbn_manifestations_#{@manifestation.id}_page_#{xisbn_page}"){@manifestation.xisbn_manifestations(:page => xisbn_page)}
      @xisbn_manifestations = @manifestation.xisbn_manifestations(:page => xisbn_page)
    end

    store_location
    canonical_url manifestation_url(@manifestation)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  {
        if params[:api] == 'amazon'
          render :xml => @manifestation.access_amazon
        else
          case params[:mode]
          when 'related'
            render :template => 'manifestations/related'
          when 'mods'
            render :template => 'manifestations/mods'
          else
            render :xml => @manifestation
          end
        end
      }
      format.json { render :json => @manifestation }
      format.atom { render :template => 'manifestations/oai_ore' }
      #format.xml  { render :action => 'mods', :layout => false }
      format.js {
        render :update do |page|
          page.replace_html 'xisbn_list', :partial => 'show_xisbn' if params[:xisbn_page]
        end
      }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /manifestations/new
  def new
    @manifestation = Manifestation.new
    @original_manifestation = get_manifestation
    @manifestation.series_statement = @series_statement
    unless params[:mode] == 'import_isbn'
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
      if @manifestation.series_statement
        @manifestation.original_title = @manifestation.series_statement.original_title
        @manifestation.title_transcription = @manifestation.series_statement.title_transcription
      elsif @original_manifestation
        @manifestation.original_title = @original_manifestation.original_title
        @manifestation.title_transcription = @original_manifestation.title_transcription
      elsif @expression
        @manifestation.original_title = @expression.original_title
        @manifestation.title_transcription = @expression.title_transcription
      end
    end
    @manifestation.language = Language.first(:conditions => {:iso_639_1 => @locale})
    @manifestation = @manifestation.set_serial_number

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation }
    end
  end

  # GET /manifestations/1;edit
  def edit
    @manifestation = Manifestation.find(params[:id])
    @original_manifestation = get_manifestation
    @manifestation.series_statement = @series_statement if @series_statement
    if params[:mode] == 'tag_edit'
      @bookmark = current_user.bookmarks.first(:conditions => {:manifestation_id => @manifestation.id}) if @manifestation rescue nil
      render :partial => 'tag_edit', :locals => {:manifestation => @manifestation}
    end
    store_location
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /manifestations
  # POST /manifestations.xml
  def create
    case params[:mode]
    when 'import_isbn'
      begin
        @manifestation = Manifestation.import_isbn(params[:manifestation][:isbn])
        @manifestation.post_to_twitter = true if params[:manifestation][:post_to_twitter] == "1"
      rescue Exception => e
        case e.message
        when 'invalid ISBN'
          flash[:notice] = t('manifestation.invalid_isbn')
        when 'already imported'
          flash[:notice] = t('manifestation.already_imported')
        else
          flash[:notice] = t('manifestation.record_not_found')
        end
        redirect_to new_manifestation_url(:mode => 'import_isbn')
        return
      end
    else
      @manifestation = Manifestation.new(params[:manifestation])
      if @manifestation.respond_to?(:post_to_twitter)
        @manifestation.post_to_twitter = true if params[:manifestation][:post_to_twitter] == "1"
      end
      if @manifestation.respond_to?(:post_to_scribd)
        @manifestation.post_to_scribd = true if params[:manifestation][:post_to_scribd] == "1"
      end
      if @manifestation.original_title.blank?
        @manifestation.original_title = @manifestation.attachment_file_name
      end
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
    end

    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          if @original_manifestation = get_manifestation
            @manifestation.derived_manifestations << @original_manifestation
          end
          # 雑誌の場合、出版者を自動的に追加
          if @manifestation.series_statement
            @manifestation.create_next_issue_work_and_expression
          end
          if @expression
            @manifestation.expressions << @expression
          end
          if @patron
            @manifestation.patrons << @expression
          end
        end

        # TODO: モデルへ移動
        if @manifestation.respond_to?(:post_to_twitter)
          @manifestation.send_later(:send_to_twitter) if @manifestation.post_to_twitter
        end
        if @manifestation.respond_to?(:post_to_scribd)
          @manifestation.send_later(:upload_to_scribd) if @manifestation.post_to_scribd
        end

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation'))
        #if params[:mode] == 'import_isbn'
        #  format.html { redirect_to edit_manifestation_url(@manifestation) }
        #  format.xml  { head :created, :location => manifestation_url(@manifestation) }
        #else
          format.html { redirect_to(@manifestation) }
          format.xml  { render :xml => @manifestation, :status => :created, :location => @manifestation }
        #end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestations/1
  # PUT /manifestations/1.xml
  def update
    @manifestation = Manifestation.find(params[:id])
    
    respond_to do |format|
      if @manifestation.update_attributes(params[:manifestation])
        @manifestation.send_later(:send_to_twitter, @manifestation.twitter_comment.to_s.truncate(60)) if @manifestation.twitter_comment
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.manifestation'))
        format.html { redirect_to @manifestation }
        format.xml  { head :ok }
        format.json { render :json => @manifestation }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation.errors, :status => :unprocessable_entity }
        format.json { render :json => @manifestation, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /manifestations/1
  # DELETE /manifestations/1.xml
  def destroy
    @manifestation = Manifestation.find(params[:id])
    @manifestation.destroy
    flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.manifestation'))

    respond_to do |format|
      format.html { redirect_to manifestations_url }
      format.xml  { head :ok }
    end
  end

  private

  def make_query(query, options = {})
    # TODO: integerやstringもqfに含める
    query = query.to_s.strip
    if options[:mode] == 'recent'
      query = "#{query} created_at_d: [NOW-1MONTH TO NOW]"
    end

    #unless options[:carrier_type].blank?
    #  query = "#{query} carrier_type_s: #{options[:carrier_type]}"
    #end

    unless options[:library].blank?
      library_list = options[:library].split.uniq.join(' and ')
      query = "#{query} library_sm: #{library_list}"
    end

    #unless options[:language].blank?
    #  query = "#{query} language_sm: #{options[:language]}"
    #end

    #unless options[:subject].blank?
    #  query = "#{query} subject_sm: #{options[:subject]}"
    #end

    unless options[:tag].blank?
      query = "#{query} tag_sm: #{options[:tag]}"
    end

    unless options[:author].blank?
      query = "#{query} author_text: #{options[:author]}"
    end

    unless options[:isbn].blank?
      query = "#{query} isbn_sm: #{options[:isbn]}"
    end

    unless options[:issn].blank?
      query = "#{query} issn_sm: #{options[:issn]}"
    end

    unless options[:lccn].blank?
      query = "#{query} lccn_sm: #{options[:lccn]}"
    end

    unless options[:nbn].blank?
      query = "#{query} nbn_sm: #{options[:nbn]}"
    end

    unless options[:publisher].blank?
      query = "#{query} publisher_text: #{options[:publisher]}"
    end

    unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages['at_least'] = options[:number_of_pages_at_least].to_i
      number_of_pages['at_most'] = options[:number_of_pages_at_most].to_i
      number_of_pages['at_least'] = "*" if number_of_pages['at_least'] == 0
      number_of_pages['at_most'] = "*" if number_of_pages['at_most'] == 0

      query = "#{query} number_of_pages_i: [#{number_of_pages['at_least']} TO #{number_of_pages['at_most']}]"
    end

    unless options[:pubdate_from].blank? and options[:pubdate_to].blank?
      pubdate = {}
      if options[:pubdate_from].blank?
        pubdate['from'] = "*"
      else
        pubdate['from'] = Time.zone.parse(options[:pubdate_from]).utc.iso8601
      end

      if options[:pubdate_to].blank?
        pubdate['to'] = "*"
      else
        pubdate['to'] = Time.zone.parse(options[:pubdate_to]).utc.iso8601
      end
      query = "#{query} date_of_publication_d: [#{pubdate['from']} TO #{pubdate['to']}]"
    end

    query = query.strip
    if query == '[* TO *]'
      #  unless params[:advanced_search]
      query = ''
      #  end
    end

    return query
  end

  def set_search_result_order(sort_by, order)
    sort = {}
    # TODO: ページ数や大きさでの並べ替え
    case sort_by
    when 'title'
      sort[:sort_by] = 'sort_title'
      sort[:order] = 'asc'
    when 'date'
      sort[:sort_by] = 'date_of_publication'
      sort[:order] = 'desc'
    else
      # デフォルトの並び方
      sort[:sort_by] = 'created_at'
      sort[:order] = 'desc'
    end
    if order == 'asc'
      sort[:order] = 'asc'
    elsif order == 'desc'
      sort[:order] = 'desc'
    end
    sort
  end

  def get_facet(search)
    search.build do
      facet :carrier_type
      facet :library
      facet :language
      facet :subject_ids
      #paginate :page => 1, :per_page => 1
    end
    search.execute!
  end

  def render_facet(search)
    results = get_facet(search)
    @facet_query = search.query.to_params[:q]
    unless results.blank?
      case params[:view]
      when "all_facet"
        @carrier_type_facet = results.facet(:carrier_type)
        @language_facet = results.facet(:language)
        @library_facet = results.facet(:library)
        #@subject_facet = results.facet(:subject_ids)
        render :partial => 'all_facet'
      when "carrier_type_facet"
        @carrier_type_facet = results.facet(:carrier_type)
        render :partial => 'carrier_type_facet'
      when "language_facet"
        @language_facet = results.facet(:language)
        render :partial => 'language_facet'
      when "library_facet"
        @library_facet = results.facet(:library)
        render :partial => 'library_facet'
      when "subject_facet"
        @subject_facet = results.facet(:subject_ids)
        render :partial => 'subject_facet'
      else
        render :nothing => true
      end
    else
      render :nothing => true
    end
  end

  def render_mode(mode)
    case mode
    when 'barcode'
      barcode = Barby::QrCode.new(@manifestation.id)
      send_data(barcode.to_png.to_blob, :disposition => 'inline', :type => 'image/png')
    when 'holding'
      render :partial => 'manifestations/show_holding', :locals => {:manifestation => @manifestation}
    when 'tag_edit'
      render :partial => 'manifestations/tag_edit'
    when 'tag_list'
      render :partial => 'manifestations/tag_list'
    when 'show_index'
      render :partial => 'manifestations/show_index', :locals => {:manifestation => @manifestation}
    when 'show_authors'
      render :partial => 'manifestations/show_authors', :locals => {:manifestation => @manifestation}
    when 'show_all_authors'
      render :partial => 'manifestations/show_authors', :locals => {:manifestation => @manifestation}
    when 'pickup'
      render :partial => 'manifestations/pickup', :locals => {:manifestation => @manifestation}
    when 'screen_shot'
      if @manifestation.screen_shot
        mime = FileWrapper.get_mime(@manifestation.screen_shot.path)
        send_file @manifestation.screen_shot.path, :type => mime, :disposition => 'inline'
      end
    else
      false
    end
  end

  def prepare_options
    if ENV['RAILS_ENV'] == 'production'
      @carrier_types = Rails.cache.fetch('CarrierType.all'){CarrierType.all}
      @roles = Rails.cache.fetch('Role.all'){Role.all}
      @languages = Rails.cache.fetch('Language.all'){Language.all}
      @frequencies = Rails.cache.fetch('Frequency.all'){Frequency.all}
      @nii_types = Rails.cache.fetch('NiiType.all'){NiiType.all}
    else
      @carrier_types = CarrierType.all
      @roles = Role.all
      @languages = Language.all
      @frequencies = Frequency.all
      @nii_types = NiiType.all
    end
  end

  def save_search_history(query, offset = 0, total = 0, user = nil)
    check_dsbl if LibraryGroup.site_config.use_dsbl
    if WRITE_SEARCH_LOG_TO_FILE
      write_search_log(query, total, user)
    else
      SearchHistory.create(:query => query, :user_id => user.try(:id), :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
    end
  end

  def get_total_count(total_query)
    if total_query.present?
      count = Sunspot.new_search(Manifestation)
      count.build do
        fulltext total_query
        paginate :page => 1, :per_page => 1
      end
      set_role_query(current_user, count)
      count.execute!.total
    else
      0
    end
  end

  def write_search_log(query, total, user)
    SEARCH_LOGGER.info "#{Time.zone.now}\t#{query}\t#{total}\t#{user}"
  end
end
