class ManifestationsController < ApplicationController
  before_filter :has_permission?, :except => :show
  #before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_expression
  before_filter :get_subject_by_term, :only => :index
  before_filter :get_manifestation, :only => :index
  before_filter :get_subscription, :only => :index
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_libraries, :only => :index
  after_filter :convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /manifestations
  # GET /manifestations.xml
  def index
    @seconds = Benchmark.realtime do
      @numdocs = Manifestation.cached_numdocs
      search = Sunspot.new_search(Manifestation)

	    if logged_in?
	      @user = current_user if @user.nil?
	    end

      @search_engines = Rails.cache.fetch('SearchEngine.all'){SearchEngine.all}

      query = params[:query].to_s
      #query = make_query(params[:query], {
      #  :mode => params[:mode],
      #  :sort => params[:sort],
      #  :tag => params[:tag],
      #  :author => params[:author],
      #  :publisher => params[:publisher],
      #  :isbn => params[:isbn],
      #  :pubdate_from => params[:pubdate_from],
      #  :pubdate_to => params[:pubdate_to],
      #  :number_of_pages_at_least => params[:number_of_pages_at_least],
      #  :number_of_pages_at_most => params[:number_of_pages_at_most],
      #})
      #session[:manifestation_ids] = [] unless session[:manifestation_ids]
      #session[:params] = {} unless session[:params]
      #session[:params][:manifestation] = params.merge(:view => nil)
      if params[:reservable] == "true"
        @reservable = "true"
      end

      manifestations = {}
      @count = {}
      if params[:format] == 'csv'
        Manifestation.per_page = 65534
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')
      total_query = query
      search.query.keywords = query

      unless query.blank?
        search = make_internal_query(search)
      end 
        #if params[:mode] == "worldcat" or params[:page].blank?
        #
        #  if params[:worldcat_page]
        #    worldcat_page = params[:worldcat_page].to_i
        #  else
        #    worldcat_page = 1
        #  end
        #  @result = Rails.cache.fetch("worldcat_search_#{URI.escape(query)}_page_#{worldcat_page}", :expires_in => 1.week){search_worldcat(:query => query, :page => worldcat_page, :per_page => Manifestation.per_page)}
        #  if @result
        #    @worldcat_results = WillPaginate::Collection.create(worldcat_page, @result.header["itemsPerPage"].to_i, @result.header["totalResults"].to_i) do |pager| pager.replace(@result.records) end
        #  else
        #    @worldcat_results = []
        #  end
        #end
        #unless params[:mode] == "worldcat"
      begin
        @count[:total] = (Sunspot.search(Manifestation) do
          keywords total_query
        end).total
        #@tags_count = @count[:total]

        if ["all_facet", "carrier_type_facet", "language_facet", "library_facet", "subject_facet"].index(params[:view])
          prepare_options
          render_facet(search)
          return
        end

        #order = set_search_result_order(params[:sort], params[:mode])
        manifestation_ids = Manifestation.search_ids do
          keywords query
        #  order_by order
          paginate :page => 1, :per_page => Manifestation.cached_numdocs
        end

        if params[:view] == "tag_cloud"
          if manifestation_ids
            @tags = Tag.bookmarked(manifestation_ids)
            render :partial => 'tag_cloud'
            return
          end
        end

        page = params[:page] || 1
        search.query.paginate(page.to_i, Manifestation.per_page)
        @manifestations = search.execute!.results
        @count[:query_result] = @manifestations.total_entries

        save_search_history(@query, @manifestations.offset, @count[:total])

        if @manifestations
          session[:manifestation_ids] = manifestation_ids
        end
      rescue
        @manifestations = WillPaginate::Collection.create(1, Manifestation.per_page, 0) do end
        @count[:total] = 0
        @count[:query_result] = 0
      end
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
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.atom
      format.json { render :json => @manifestations }
      format.js {
        render :update do |page|
          page.replace_html 'worldcat_list', :partial => 'worldcat' if params[:worldcat_page]
        end
      }
    end
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
        redirect_to manifestation_url(@manifestation)
        return
      else
        raise ActiveRecord::RecordNotFound if @manifestation.nil?
      end
    else
      @manifestation = Manifestation.find(params[:id])
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
    @reserve = current_user.reserves.find(:first, :conditions => {:manifestation_id => @manifestation}) if logged_in?

    if @manifestation.respond_to?(:worldcat_record)
      @worldcat_record = Rails.cache.fetch("worldcat_record_#{@manifestation.id}"){@manifestation.worldcat_record}
    end
    if @manifestation.respond_to?(:xisbn_manifestations)
      if params[:xisbn_page]
        xisbn_page = params[:xisbn_page].to_i
      else
        xisbn_page = 1
      end
      @xisbn_manifestations = Rails.cache.fetch("xisbn_manifestations_#{@manifestation.id}_page_#{xisbn_page}"){@manifestation.xisbn_manifestations(:page => xisbn_page)}
      #@xisbn_manifestations = @manifestation.xisbn_manifestations(:page => xisbn_page)
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
    unless params[:mode] == 'import_isbn'
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
      if @expression
        @manifestation.original_title = @expression.original_title
        @manifestation.set_serial_number(@expression)
      end
    end
    @manifestation.language = Language.find(:first, :conditions => {:iso_639_1 => @locale})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @manifestation }
    end
  end

  # GET /manifestations/1;edit
  def edit
    @manifestation = Manifestation.find(params[:id])
    if params[:mode] == 'tag_edit'
      @bookmark = current_user.bookmarks.find(:first, :conditions => {:bookmarked_resource_id => @manifestation.bookmarked_resource.id}) if @manifestation.bookmarked_resource rescue nil
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
      @manifestation.post_to_twitter = true if params[:manifestation][:post_to_twitter] == "1"
      @manifestation.post_to_scribd = true if params[:manifestation][:post_to_scribd] == "1"
      if @manifestation.original_title.blank?
        @manifestation.original_title = @manifestation.attachment_file_name
      end
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
      last_issue = @expression.last_issue if @expression
    end

    @manifestation.indexing = true
    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          # 雑誌の場合、出版者を自動的に追加
          if @expression
            @expression.manifestations << @manifestation
            @manifestation.patrons << last_issue.patrons if last_issue
          end
        end

        # TODO: モデルへ移動
        @manifestation.send_later(:send_to_twitter) if @manifestation.post_to_twitter
        @manifestation.send_later(:upload_to_scribd) if @manifestation.post_to_scribd

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation'))
        #if params[:mode] == 'import_isbn'
        #  format.html { redirect_to edit_manifestation_url(@manifestation) }
        #  format.xml  { head :created, :location => manifestation_url(@manifestation) }
        #else
          unless @manifestation.patrons.empty?
            format.html { redirect_to(@manifestation) }
            format.xml  { render :xml => @manifestation, :status => :created, :location => @manifestation }
          else
            format.html { redirect_to manifestation_patrons_url(@manifestation) }
            format.xml  { render :xml => @manifestation, :status => :created, :location => @manifestation }
          end
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
    params[:isbn] = params[:isbn].gsub(/\D/, "") if params[:isbn]
    
    @manifestation.indexing = true
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
    @manifestation.indexing = true
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
    #if options[:mode] == 'recent'
    #  query = "#{query} created_at_time: [NOW-1MONTH TO NOW]"
    #end
    #unless options[:carrier_type].blank?
    #  query = "#{query} carrier_type: #{options[:carrier_type]}"
    #end

    #unless options[:library].blank?
    #  library_list = options[:library].split.uniq.join(' and ')
    #  query = "#{query} library: #{library_list}"
    #end

    #unless options[:language].blank?
    #  query = "#{query} lang: #{options[:language]}"
    #end

    #unless options[:tag].blank?
    #  query = "#{query} tag_string: #{options[:tag]}"
    #end

    unless options[:author].blank?
      query = "#{query} author_text: #{options[:author]}"
    end

    #unless options[:isbn].blank?
    #  query = "#{query} isbn_string: #{options[:isbn]}"
    #end

    unless options[:publisher].blank?
      query = "#{query} publisher_text: #{options[:publisher]}"
    end

    #unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
    #  number_of_pages = {}
    #  number_of_pages['at_least'] = options[:number_of_pages_at_least].to_i
    #  number_of_pages['at_most'] = options[:number_of_pages_at_most].to_i
    #  number_of_pages['at_least'] = "*" if number_of_pages['at_least'] == 0
    #  number_of_pages['at_most'] = "*" if number_of_pages['at_most'] == 0
    #
    #  query = "#{query} number_of_pages: [#{number_of_pages['at_least']} TO #{number_of_pages['at_most']}]"
    #end

    #unless options[:pubdate_from].blank? and options[:pubdate_to].blank?
    #  pubdate = {}
    #  if options[:pubdate_from].blank?
    #    pubdate['from'] = "*"
    #  else
    #    pubdate['from'] = Time.zone.local(options[:pubdate_from]).utc.iso8601
    #  end
    #
    #  if options[:pubdate_to].blank?
    #    pubdate['to'] = "*"
    #  else
    #    pubdate['to'] = Time.zone.local(options[:pubdate_to]).utc.iso8601
    #  end
    #  query = "#{query} pubdate: [#{pubdate['from']} TO #{pubdate['to']}]"
    #end

    query = query.strip
    if query == '[* TO *]'
    #  unless params[:advanced_search]
        query = ''
    #  end
    end

    return query
  end

  def set_search_result_order(sort, mode)
    # TODO: ページ数や大きさでの並べ替え
    if mode == 'recent'
      order = 'created_at desc'
    else
      case sort
      when 'title'
        order = 'sort_title asc'
      when 'date'
        order = 'pubdate desc'
      else
        order = 'created_at desc' # デフォルトの並び方
      end
    end
  end

  def get_facet(search)
    search.query.add_field_facet(:carrier_type)
    search.query.add_field_facet(:library)
    search.query.add_field_facet(:language)
    search.query.add_field_facet(:subject)
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
        @subject_facet = results.facet(:subject)
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
        @subject_facet = results.facet(:subject)
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
        mime = MIME.check_magics(@manifestation.screen_shot.open)
        send_file @manifestation.screen_shot.path, :type => mime.to_s, :disposition => 'inline'
      end
    else
      false
    end
  end

  def make_internal_query(search)
    # 内部的なクエリ
    unless params[:mode] == "add"
      search.query.add_restriction(:expression_id, :equal_to, @expression.id) if @expression
      search.query.add_restriction(:patron_id, :equal_to, @patron.id) if @patron
      search.query.add_restriction(:original_manifestation_ids, :equal_to, @manifestation.id) if @manifestation
      unless @subscription.blank?
        search.query.add_restriction(:subscription_id, :equal_to, @subscription.id)
        search.query.add_restriction(:subscription_master, :equal_to, true)
      end
    end
    search.query.add_restriction(:reservable, :equal_to, true) if @reservable
    search.query.add_restriction(:subject, :equal_to, @subject_by_term) if @subject_by_term
    unless params[:carrier_type].blank?
      carrier_type = CarrierType.find(:first, :conditions => {:name => params[:carrier_type]})
      search.query.keywords = "#{search.query.to_params[:q]} carrier_type: (#{carrier_type.name})"
    end
    unless params[:library].blank?
      library_list = params[:library].split.uniq.join(' ')
      search.query.keywords = "#{search.query.to_params[:q]} library: (#{library_list})"
    end
    unless params[:language].blank?
      language_list = params[:language].split.uniq.join(' ')
      search.query.keywords = "#{search.query.to_params[:q]} language: (#{language_list})"
    end
    return search
  end

  def prepare_options
    @carrier_types = Rails.cache.fetch('CarrierType.all'){CarrierType.all}
    @roles = Rails.cache.fetch('Role.all'){Role.all}
    @languages = Rails.cache.fetch('Language.all'){Language.all}
    @frequencies = Frequency.find(:all)
  end

  def save_search_history(query, offset = 0, total = 0)
    check_dsbl if LibraryGroup.site_config.use_dsbl
    if logged_in?
      @history = SearchHistory.create(:query => query, :user_id => nil, :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
    end
  end

  def search_worldcat(search_options, translate_from = I18n.locale, translate_into = 'English', translate_method = 'google')
    if translate_method == 'mecab'
      # romanize
      query = Kakasi::kakasi('-Ha -Ka -Ja -Ea -ka', NKF::nkf('-e', search_options[:query].wakati.yomi))
    else
      query = Translate.t(search_options[:query], translate_from, translate_into)
    end
    Manifestation.search_worldcat(:query => query, :page => search_options[:page], :per_page => search_options[:per_page])
  end

  def get_subject_by_term
    @subject_by_term = Subject.find(:first, :conditions => {:term => params[:subject]}) if params[:subject]
  end
end
