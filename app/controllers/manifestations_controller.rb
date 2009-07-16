class ManifestationsController < ApplicationController
  before_filter :has_permission?, :except => :show
  #before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_expression
  before_filter :get_subject
  before_filter :get_manifestation, :only => :index
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_libraries, :only => :index
  after_filter :convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /manifestations
  # GET /manifestations.xml
  def index
    @seconds = Benchmark.realtime do
      @numdocs = Manifestation.cached_numdocs

	    if logged_in?
	      @user = current_user if @user.nil?
	    end

      @subject_by_term = Subject.find(:first, :conditions => {:term => params[:subject]}) if params[:subject]

      #@manifestation_form = ManifestationForm.find(:first, :conditions => {:name => params[:formtype]})
      @search_engines = Rails.cache.fetch('SearchEngine.all'){SearchEngine.all}

      query = make_query(params[:query], {
        :mode => params[:mode],
        :sort => params[:sort],
        :tag => params[:tag],
        :author => params[:author],
        :publisher => params[:publisher],
        :isbn => params[:isbn],
        :pubdate_from => params[:pubdate_from],
        :pubdate_to => params[:pubdate_to],
        :number_of_pages_at_least => params[:number_of_pages_at_least],
        :number_of_pages_at_most => params[:number_of_pages_at_most],
        #:formtype => params[:formtype],
        #:library => params[:library],
        #:language => params[:language],
        #:subject => params[:subject],
      })
      session[:manifestation_ids] = [] unless session[:manifestation_ids]
      session[:params] = {} unless session[:params]
      session[:params][:manifestation] = params.merge(:view => nil)
      if params[:reservable] == "true"
        @reservable = "true"
      end

      @query = query.dup
      manifestations = {}
      @count = {}
      if params[:format] == 'csv'
        Manifestation.per_page = 65534
      end

      # 絞り込みを行わない状態のクエリ
      query = query.gsub('　', ' ')
      total_query = query

      unless query.blank?
        query = make_internal_query(query)
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
            @count[:total] = Manifestation.count_by_solr(total_query)
            #@tags_count = @count[:total]

            if ["all_facet", "manifestation_form_facet", "language_facet", "library_facet", "subject_facet"].index(params[:view])
              prepare_options
              render_facet(query)
              return
            end

            order = set_search_result_order(params[:sort], params[:mode])
            #browse = "manifestation_form_f: #{@manifestation_form.name}" if @manifestation_form
            browse = ""

            manifestation_ids = Manifestation.find_id_by_solr(query, :order => order, :limit => Manifestation.cached_numdocs).results
            if params[:view] == "tag_cloud"
              if manifestation_ids
                @tags = Tag.bookmarked(manifestation_ids)
                render :partial => 'tag_cloud'
                return
              end
            end

            @manifestations = Manifestation.paginate_by_solr(query, :facets => {:browse => browse}, :order => order, :page => params[:page]).compact
            @count[:query_result] = @manifestations.total_entries
        
            save_search_history(@query, @manifestations.offset, @count[:total])

            if @manifestations
              session[:manifestation_ids] = manifestation_ids
            end
          rescue
            @manifestations = []
            @count[:total] = 0
            @count[:query_result] = 0
          end
        #end
      else
        # Solrを使わない場合
        get_index_without_solr
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
    query = query.to_s.strip
    if options[:mode] == 'recent'
      query = "#{query} created_at: [NOW-1MONTH TO NOW]"
    end
    #unless options[:formtype].blank?
    #  query = "#{query} formtype: #{options[:formtype]}"
    #end

    #unless options[:library].blank?
    #  library_list = options[:library].split.uniq.join(' and ')
    #  query = "#{query} library: #{library_list}"
    #end

    #unless options[:language].blank?
    #  query = "#{query} lang: #{options[:language]}"
    #end

    unless options[:tag].blank?
      query = "#{query} tag: #{options[:tag]}"
    end

    unless options[:author].blank?
      query = "#{query} author: #{options[:author]}"
    end

    unless options[:isbn].blank?
      query = "#{query} isbn: #{options[:isbn]}"
    end

    unless options[:publisher].blank?
      query = "#{query} publisher: #{options[:publisher]}"
    end

    unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages['at_least'] = options[:number_of_pages_at_least].to_i
      number_of_pages['at_most'] = options[:number_of_pages_at_most].to_i
      number_of_pages['at_least'] = "*" if number_of_pages['at_least'] == 0
      number_of_pages['at_most'] = "*" if number_of_pages['at_most'] == 0

      query = "#{query} number_of_pages: [#{number_of_pages['at_least']} TO #{number_of_pages['at_most']}]"
    end

    unless options[:pubdate_from].blank? and options[:pubdate_to].blank?
      pubdate = {}
      if options[:pubdate_from].blank?
        pubdate['from'] = "*"
      else
        pubdate['from'] = Time.zone.local(options[:pubdate_from]).utc.iso8601
      end

      if options[:pubdate_to].blank?
        pubdate['to'] = "*"
      else
        pubdate['to'] = Time.zone.local(options[:pubdate_to]).utc.iso8601
      end
      query = "#{query} pubdate: [#{pubdate['from']} TO #{pubdate['to']}]"
    end

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
        order = 'sortable_title asc'
      when 'date'
        order = 'pubdate desc'
      else
        order = 'created_at desc' # デフォルトの並び方
      end
    end
  end

  def get_facet(query)
    result = Manifestation.find_by_solr(query, {:facets => {:zeros => false, :fields => [:formtype_f, :library_f, :language_f, :subject_f]}})
    return result.facets["facet_fields"]
  rescue
    nil
  end

  def render_facet(query)
    @facet_results = get_facet(query)
    @facet_query = query
    unless @facet_results.blank?
      case params[:view]
      when "all_facet"
        render :partial => 'all_facet'
      when "manifestation_form_facet"
        render :partial => 'manifestation_form_facet'
      when "language_facet"
        render :partial => 'language_facet'
      when "library_facet"
        render :partial => 'library_facet'
      when "subject_facet"
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

  def get_index_without_solr
    case
    when @patron
      @manifestations = @patron.manifestations.paginate(:page => params[:page], :include => :manifestation_form, :order => ['produces.id'])
    when @expression
      @manifestations = @expression.manifestations.paginate(:page => params[:page], :include => :manifestation_form, :order => ['embodies.id'])
    when @manifestation
      if params[:mode] == 'add'
        @manifestations = Manifestation.paginate(:all, :page => params[:page], :order => 'manifestations.id')
      else
        @manifestations = @manifestation.derived_manifestations.paginate(:page => params[:page], :order => 'manifestations.id DESC')
      end
    when @subject
      @manifestations = @subject.manifestations.paginate(:page => params[:page], :include => :manifestation_form, :order => ['resource_has_subjects.id'])
    else
      #@manifestations = Manifestation.paginate(:all, :page => params[:page], :include => :manifestation_form, :order => ['manifestations.id'])
      @manifestations = []
    end
    @count[:total] = @manifestations.size
    @count[:query_result] = @manifestations.size
    #flash[:notice] = ('Enter your search term.')
  end

  def make_internal_query(query)
    # 内部的なクエリ
    unless params[:mode] == "add"
      query.add_query!(@expression) unless @expression.blank?
      query.add_query!(@patron) unless @patron.blank?
      query = "#{query} original_manifestation_ids: #{manifestation_form.name}" if @manifestation
    end
    if @reservable
      query = "#{query} reservable: true"
    end
    #query.add_query!(@manifestation_form) unless @manifestation_form.blank?
    query.add_query!(@subject_by_term) unless @subject_by_term.blank?
    unless params[:formtype].blank?
      manifestation_form = ManifestationForm.find(:first, :conditions => {:name => params[:formtype]})
      query = "#{query} formtype: #{manifestation_form.name}"
    end
    unless params[:library].blank?
      library_list = params[:library].split.uniq.join(' ')
      query = "#{query} library: (#{library_list})"
    end
    unless params[:language].blank?
      language_list = params[:language].split.uniq.join(' ')
      query = "#{query} lang: (#{language_list})"
    end
    return query
  end

  def prepare_options
    @manifestation_forms = Rails.cache.fetch('ManifestationForm.all'){ManifestationForm.all}
    @roles = Rails.cache.fetch('Role.all'){Role.all}
    @languages = Rails.cache.fetch('Language.all'){Language.all}
  end

  def save_search_history(query, offset = 0, total = 0)
    check_dsbl if LibraryGroup.site_config.use_dsbl
    if logged_in?
      SearchHistory.create(:query => query, :user_id => nil, :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
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

end
