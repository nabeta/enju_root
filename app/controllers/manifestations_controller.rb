class ManifestationsController < ApplicationController
  before_filter :has_permission?, :except => :show
  #before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_expression
  before_filter :get_subject
  before_filter :store_location, :except => [:index, :create, :update, :destroy]
  before_filter :prepare_options, :only => [:new, :edit]
  after_filter :csv_convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /manifestations
  # GET /manifestations.xml
  def index
    @seconds = Benchmark.realtime do
      @numdocs = Manifestation.numdocs

	    if logged_in?
	      @user = current_user if @user.nil?
	    end

      prepare_options
      @libraries = Library.find(:all, :order => 'position')
      @subject_by_term = Subject.find(:first, :conditions => {:term => params[:subject]}) if params[:subject]

      @manifestation_form = ManifestationForm.find(:first, :conditions => {:name => params[:formtype]})
      @search_engines = SearchEngine.find(:all, :order => :position)

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
        per_page = 65534
      else
        per_page = Manifestation.per_page
      end

      # 絞り込みを行わない状態のクエリ
      total_query = query

      unless query.blank?
        unless params[:mode] == "add"
          query.add_query!(@expression) unless @expression.blank?
          query.add_query!(@patron) unless @patron.blank?
        end
        # 内部的なクエリ
        if @reservable
          query = "#{query} reservable: true"
        end
        query.add_query!(@manifestation_form) unless @manifestation_form.blank?
        query.add_query!(@subject_by_term) unless @subject_by_term.blank?
        unless params[:library].blank?
          library_list = params[:library].split.uniq.join(' ')
          query = "#{query} library: (#{library_list})"
        end
        unless params[:language].blank?
          language_list = params[:language].split.uniq.join(' ')
          query = "#{query} lang: (#{language_list})"
        end

        begin
          @count[:total] = Manifestation.count_by_solr(total_query)
          #@tags_count = @count[:total]

          if ["all_facet", "manifestation_form_facet", "language_facet", "library_facet", "subject_facet"].index(params[:view])
            render_facet(query)
            return
          end

          order = set_search_result_order(params[:sort], params[:mode])
          #browse = "manifestation_form_f: #{@manifestation_form.name}" if @manifestation_form
          browse = ""

          manifestation_ids = Manifestation.find_id_by_solr(query, :order => order, :limit => Manifestation.numdocs).results
          if params[:view] == "tag_cloud"
            if manifestation_ids
              @tags = Tag.bookmarked(manifestation_ids)
              render :partial => 'tag_cloud'
              return
            end
          end

          @manifestations = Manifestation.paginate_by_solr(query, :facets => {:browse => browse}, :order => order, :page => params[:page], :per_page => per_page).compact
          @count[:query_result] = @manifestations.total_entries
        
          if @manifestations
            session[:manifestation_ids] = manifestation_ids
          end
        rescue
          @manifestations = []
          @count[:total] = 0
          @count[:query_result] = 0
        end
      else
        # Solrを使わない場合
        get_index_without_solr
      end

      unless @query.blank?
        #check_dsbl if LibraryGroup.find(1).use_dsbl?
        if logged_in?
          SearchHistory.create(:query => @query, :user_id => nil, :start_record => @manifestations.offset + 1, :maximum_records => nil, :number_of_records => @count[:total])
        end
      end
    end
    store_location

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
    end
  end

  # GET /manifestations/1
  # GET /manifestations/1.xml
  def show
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

    return if render_mode(params[:mode])

    @reserved_count = Reserve.waiting.count(:all, :conditions => {:manifestation_id => @manifestation, :checked_out_at => nil})
    @reserve = current_user.reserves.find(:first, :conditions => {:manifestation_id => @manifestation}) if logged_in?

    @amazon_reviews = @manifestation.amazon_customer_review

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @manifestation }
      format.json { render :json => @manifestation }
      #format.xml  { render :action => 'mods', :layout => false }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /manifestations/new
  def new
    if params[:mode] == 'import_isbn'
      @manifestation = Manifestation.new
    else
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
      @manifestation = Manifestation.new
      if @expression
        @manifestation.original_title = @expression.original_title
        @manifestation.set_serial_number(@expression)
      end
    end
    @manifestation.language = Language.find(:first, :conditions => {:iso_639_1 => I18n.default_locale})

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
      render :partial => 'tag_edit'
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /manifestations
  # POST /manifestations.xml
  def create
    if params[:mode] == 'import_isbn'
      begin
        @manifestation = Manifestation.import_isbn(params[:manifestation][:isbn])
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
      #unless @expression
      #  flash[:notice] = t('manifestation.specify_expression')
      #  redirect_to expressions_url
      #  return
      #end
      last_issue = @expression.last_issue if @expression
      @manifestation = Manifestation.new(params[:manifestation])
    end

    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          # 雑誌の場合、出版者を自動的に追加
          if @expression
            @expression.manifestations << @manifestation
            @manifestation.patrons << last_issue.patrons if last_issue
          end
        end

        # tsvなどでのインポート時に大量にpostされないようにするため、
        # コントローラで処理する
        @manifestation.post_to_twitter

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation'))
        #if params[:mode] == 'import_isbn'
        #  format.html { redirect_to edit_manifestation_url(@manifestation) }
        #  format.xml  { head :created, :location => manifestation_url(@manifestation) }
        #else
          unless @manifestation.patrons.blank?
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
    
    respond_to do |format|
      if @manifestation.update_attributes(params[:manifestation])
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

  def add_query(query, object)
    case object.class.to_s
    when 'ManifestationForm'
      query = "#{query} formtype: #{object.name}"
    when 'Language'
      query = "#{query} lang: #{object.name}"
    end
    return query
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
    when 'show_authors'
      render :partial => 'manifestations/show_authors'
    when 'show_all_authors'
      render :partial => 'manifestations/show_authors'
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
    when @parent_manifestation
      @manifestations = @parent_manifestation.derived_manifestations.paginate(:page => params[:page], :order => 'manifestations.id')
    when @derived_manifestation
      @manifestations = @derived_manifestation.parent_manifestations.paginate(:page => params[:page], :order => 'manifestations.id')
    when @subject
      @manifestations = @subject.manifestations.paginate(:page => params[:page], :include => :manifestation_form, :order => ['resource_has_subjects.id'])
    else
      #@manifestations = Manifestation.paginate(:all, :page => params[:page], :per_page => @per_page, :include => :manifestation_form, :order => ['manifestations.id'])
      @manifestations = []
    end
    @count[:total] = @manifestations.size
    @count[:query_result] = @manifestations.size
    #flash[:notice] = ('Enter your search term.')
  end

  def prepare_options
    @manifestation_forms = ManifestationForm.find(:all, :order => 'position')
    @languages = Language.find(:all, :order => 'position')
    @roles = Role.find(:all, :order => 'id desc')
  end

end
