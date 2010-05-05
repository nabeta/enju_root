# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!, :only => :edit
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
  include OaiController

  # GET /manifestations
  # GET /manifestations.xml
  def index
    @seconds = Benchmark.realtime do
      @oai = check_oai_params(params)
      next if @oai[:need_not_to_search]
	    if user_signed_in?
	      @user = current_user unless @user
	    end

      if params[:format] == 'oai'
        from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
        from_time = @from_time = from_and_until_times[:from]
        until_time = @until_time = from_and_until_times[:until]
        # OAI-PMHのデフォルトの件数
        per_page = 200
        if params[:resumptionToken]
          if current_token = get_resumption_token(params[:resumptionToken])
            page = (current_token[:cursor].to_i + per_page).div(per_page) + 1
          else
            @oai[:errors] << 'badResumptionToken'
          end
        else
        end
        page ||= 1

        if params[:verb] == 'GetRecord' and params[:identifier]
          begin
            @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
          rescue ActiveRecord::RecordNotFound
            @oai[:errors] << "idDoesNotExist"
            render :template => 'manifestations/index.oai.builder'
            return
          end
          render :template => 'manifestations/show.oai.builder'
          return
        end
      end

      case params[:reservable]
      when 'true'
        @reservable = 'true'
      when 'false'
        @reservable = 'false'
      else
        @reservable = nil
      end

      if params[:format] == 'csv'
        per_page = 65534
        #rows = Manifestation.count
      end

      manifestations = {}
      @count = {}
      query = ""
      sort = {}

			case
      when params[:format] == 'sru'
        if params[:operation] == 'searchRetrieve'
          @sru = Sru.new(params)
          query = @sru.cql.to_sunspot
          sort = @sru.sort_by
        else
          render :template => 'manifestations/index.explain.xml', :layout => false
          return
        end
      when params[:api] == 'openurl' 
        @openurl = Openurl.new(params)
        @manifestations = @openurl.search
        query = @openurl.query_text
        sort = set_search_result_order(params[:sort_by], params[:order])
      else
        query = make_query(params[:query], params)
        sort = set_search_result_order(params[:sort_by], params[:order])
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      search = Sunspot.new_search(Manifestation)
      role = current_user.try(:highest_role) || Role.find(1)
      oai_search = true if params[:format] == 'oai'
      case @reservable
      when 'true'
        reservable = true
      when 'false'
        reservable = false
      else
        reservable = nil
      end
      search.build do
        fulltext query unless query.blank?
        order_by sort[:sort_by], sort[:order] unless oai_search
        order_by :updated_at, :desc if oai_search
        with(:required_role_id).less_than role.id
        with(:repository_content).equal_to true if oai_search
        with(:reservable).equal_to reservable unless reservable.nil?
        with(:updated_at).greater_than from_time if from_time
        with(:updated_at).less_than until_time if until_time
        paginate :page => 1, :per_page => MAX_NUMBER_OF_RESULTS
      end
      @count[:query_result] = search.execute!.total

      search = make_internal_query(search)

      if session[:search_params]
        unless search.query.to_params == session[:search_params]
          clear_search_sessions
        end
      else
        clear_search_sessions
        session[:params] = params
        session[:search_params] == search.query.to_params
        session[:query] = @query
      end

      unless session[:manifestation_ids]
        manifestation_ids = search.build do
          paginate :page => 1, :per_page => MAX_NUMBER_OF_RESULTS
        end.execute!.raw_results.collect(&:primary_key).map{|id| id.to_i}
        session[:manifestation_ids] = manifestation_ids
      end
        
      if session[:manifestation_ids]
        bookmark_ids = Bookmark.all(:select => :id, :conditions => {:manifestation_id => session[:manifestation_ids]}).collect(&:id)
        @tags = Tag.bookmarked(bookmark_ids)
        if params[:view] == 'tag_cloud'
          render :partial => 'tag_cloud'
          #session[:manifestation_ids] = nil
          return
        end
      end

      page ||= params[:page] || 1
      if params[:format] == 'sru'
        search.query.start_record(params[:startRecord] || 1, params[:maximumRecords] || 200)
      else
        search.build do
          facet :reservable
          facet :carrier_type
          facet :library
          facet :language
          facet :subject_ids
          paginate :page => page.to_i, :per_page => per_page || Manifestation.per_page
        end
      end
      search_result = search.execute!
      @manifestations = search_result.results
      @manifestations.total_entries = MAX_NUMBER_OF_RESULTS if @count[:query_result] > MAX_NUMBER_OF_RESULTS

      @carrier_type_facet = search_result.facet(:carrier_type)
      @language_facet = search_result.facet(:language)
      @library_facet = search_result.facet(:library)
      @reservable_facet = search_result.facet(:reservable)

      @search_engines = SearchEngine.all

      # TODO: 検索結果が少ない場合にも表示させる
      if manifestation_ids.blank?
        if query.respond_to?(:suggest_tags)
          @suggested_tag = query.suggest_tags.first
        end
      end
      save_search_history(query, @manifestations.offset, @count[:query_result], current_user)
      if params[:format] == 'oai'
        unless @manifestations.empty?
          set_resumption_token(@manifestations, @from_time || Manifestation.last.updated_at, @until_time || Manifestation.first.updated_at)
        else
          @oai[:errors] << 'noRecordsMatch'
        end
      end
    end

    store_location # before_filter ではファセット検索のURLを記憶してしまう

    respond_to do |format|
      format.html
      format.xml  { render :xml => @manifestations }
      format.sru  { render :layout => false }
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.rdf  { render :layout => false }
      format.atom
      format.oai {
        case params[:verb]
        when 'Identify'
          render :template => 'manifestations/identify'
        when 'ListMetadataFormats'
          render :template => 'manifestations/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.all
          render :template => 'manifestations/list_sets'
        when 'ListIdentifiers'
          render :template => 'manifestations/list_identifiers'
        when 'ListRecords'
          render :template => 'manifestations/list_records'
        end
      }
      format.mods
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
  #rescue RSolr::RequestError
  #  unless params[:format] == 'sru'
  #    flash[:notice] = t('page.error_occured')
  #    redirect_to manifestations_url
  #    return
  #  else
  #    render :template => 'manifestations/error.xml', :layout => false
  #    return
  #  end
  #  return
  rescue QueryError => e
    render :template => 'manifestations/error.xml', :layout => false
    Rails.logger.info "#{Time.zone.now}\t#{query}\t\t#{current_user.try(:username)}\t#{e}"
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

    case params[:mode]
    when 'send_email'
      if user_signed_in?
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
    @reserve = current_user.reserves.first(:conditions => {:manifestation_id => @manifestation}) if user_signed_in?

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
          else
            render :xml => @manifestation
          end
        end
      }
      format.rdf
      format.oai
      format.mods
      format.json { render :json => @manifestation }
      #format.atom { render :template => 'manifestations/oai_ore' }
      #format.xml  { render :action => 'mods', :layout => false }
      format.js {
        render :update do |page|
          page.replace_html 'xisbn_list', :partial => 'show_xisbn' if params[:xisbn_page]
        end
      }
      format.pdf {
        prawnto :prawn => {
          :page_layout => :portrait,
          :page_size => "A4"},
          :inline => true
      }
    end
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
    unless current_user.has_role?('Librarian')
      unless params[:mode] == 'tag_edit'
        access_denied; return
      end
    end
    @manifestation = Manifestation.find(params[:id])
    @original_manifestation = get_manifestation
    @manifestation.series_statement = @series_statement if @series_statement
    if params[:mode] == 'tag_edit'
      @bookmark = current_user.bookmarks.first(:conditions => {:manifestation_id => @manifestation.id}) if @manifestation rescue nil
      render :partial => 'tag_edit', :locals => {:manifestation => @manifestation}
    end
    store_location unless params[:mode] == 'tag_edit'
  end

  # POST /manifestations
  # POST /manifestations.xml
  def create
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
        format.js {
          page.replace_html 'tag_list', :partial => 'manifestations/tag_list'
        }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation.errors, :status => :unprocessable_entity }
        format.json { render :json => @manifestation, :status => :unprocessable_entity }
      end
    end
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

    #unless options[:library].blank?
    #  library_list = options[:library].split.uniq.join(' and ')
    #  query = "#{query} library_sm: #{library_list}"
    #end

    #unless options[:language].blank?
    #  query = "#{query} language_sm: #{options[:language]}"
    #end

    #unless options[:subject].blank?
    #  query = "#{query} subject_sm: #{options[:subject]}"
    #end

    unless options[:tag].blank?
      query = "#{query} tag_sm: #{options[:tag]}"
    end

    unless options[:creator].blank?
      query = "#{query} creator_text: #{options[:creator]}"
    end

    unless options[:contributor].blank?
      query = "#{query} contributor_text: #{options[:contributor]}"
    end

    unless options[:isbn].blank?
      query = "#{query} isbn_sm: #{options[:isbn]}"
    end

    unless options[:issn].blank?
      query = "#{query} issn_s: #{options[:issn]}"
    end

    unless options[:lccn].blank?
      query = "#{query} lccn_s: #{options[:lccn]}"
    end

    unless options[:nbn].blank?
      query = "#{query} nbn_s: #{options[:nbn]}"
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
        pubdate['from'] = Time.zone.parse(options[:pubdate_from]).beginning_of_day.utc.iso8601
      end

      if options[:pubdate_to].blank?
        pubdate['to'] = "*"
      else
        pubdate['to'] = Time.zone.parse(options[:pubdate_to]).tomorrow.beginning_of_day.utc.iso8601
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
    when 'pubdate'
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
    when 'calil_list'
      render :partial => 'manifestations/calil_list'
    else
      false
    end
  end

  def prepare_options
    if Rails.env == 'production'
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
      history = SearchHistory.create(:query => query, :user => user, :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
    end
  end

  def write_search_log(query, total, user)
    SEARCH_LOGGER.info "#{Time.zone.now}\t#{query}\t#{total}\t#{user.try(:username)}\t#{params[:format]}"
  end

end
