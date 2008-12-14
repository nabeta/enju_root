class ManifestationsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  #before_filter :get_user_if_nil
  before_filter :get_patron
  before_filter :get_expression
  before_filter :get_subject
  before_filter :store_location, :except => [:index, :create, :update, :destroy]
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

      @libraries = Library.find(:all, :order => 'position')
      @languages = Language.find(:all, :order => 'position')
      @subject_by_term = Subject.find(:first, :conditions => {:term => params[:subject]}) if params[:subject]

      @manifestation_form = ManifestationForm.find(:first, :conditions => {:name => params[:formtype]})
      @manifestation_forms = ManifestationForm.find(:all, :order => 'position')

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
      session[:params][:bookmarked_resource] = nil

      @query = query
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
          query = add_query(query, @expression) unless @expression.blank?
          query = add_query(query, @patron) unless @patron.blank?
        end
        # 内部的なクエリ
        query = add_query(query, @manifestation_form) unless @manifestation_form.blank?
        query = add_query(query, @subject_by_term) unless @subject_by_term.blank?
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
            @facet_results = get_facet(query)
            @facet_query = query
            unless @facet_results.blank?
              case params[:view]
              when "all_facet"
                render :partial => 'all_facet'
                return
              when "manifestation_form_facet"
                render :partial => 'manifestation_form_facet'
                return
              when "language_facet"
                render :partial => 'language_facet'
                return
              when "library_facet"
                render :partial => 'library_facet'
                return
              when "subject_facet"
                render :partial => 'subject_facet'
                return
              end
            end
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
        case
        when @patron
          @manifestations = @patron.manifestations.paginate(:page => params[:page], :per_page => @per_page, :include => :manifestation_form, :order => ['produces.id'])
        when @expression
          @manifestations = @expression.manifestations.paginate(:page => params[:page], :per_page => @per_page, :include => :manifestation_form, :order => ['embodies.id'])
        when @subject
          @manifestations = @subject.manifestations.paginate(:page => params[:page], :per_page => @per_page, :include => :manifestation_form, :order => ['resource_has_subjects.id'])
        else
          #@manifestations = Manifestation.paginate(:all, :page => params[:page], :per_page => @per_page, :include => :manifestation_form, :order => ['manifestations.id'])
          @manifestations = []
        end
        @count[:total] = @manifestations.size
        @count[:query_result] = @manifestations.size
        #flash[:notice] = ('Enter your search term.')
      end

      @startrecord = (params[:page].to_i - 1) * per_page + 1
      if @startrecord < 1
        @startrecord = 1
      end

      #SearchHistory.create(:query => query, :user => @user, :start_record => @startrecord, :maximum_records => nil, :number_of_records => @count[:total])
      unless @query.blank?
        check_dsbl if LibraryGroup.find(1).use_dsbl?
        SearchHistory.create(:query => @query, :user_id => nil, :start_record => @startrecord, :maximum_records => nil, :number_of_records => @count[:total])
      end
    end

    store_location
    @search_engines = SearchEngine.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.rhtml
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

    case params[:mode]
    when 'barcode'
      barcode = Barby::QrCode.new(@manifestation.id)
      send_data(barcode.to_png.to_blob, :disposition => 'inline', :type => 'image/png')
      return
    when 'holding'
      render :partial => 'show_holding'
      return
    when 'tag_edit'
      render :partial => 'tag_edit'
      return
    when 'tag_list'
      render :partial => 'tag_list'
      return
    when 'show_authors'
      render :partial => 'show_authors'
      return
    when 'show_all_authors'
      render :partial => 'show_authors'
      return
    end

    @reserved_count = Reserve.count(:all, :conditions => {:manifestation_id => @manifestation, :checked_out_at => nil})
    @reserve = current_user.reserves.find(:first, :conditions => {:manifestation_id => @manifestation}) if logged_in?

    @amazon_reviews = @manifestation.amazon_customer_review

    respond_to do |format|
      format.html # show.rhtml
      #format.json { render :json => @manifestation.to_json }# show.rhtml
      format.xml  { render :xml => @manifestation }
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
      unless @expression
        flash[:notice] = ('Please specify expression id.')
        redirect_to expressions_url
        return
      end
      @manifestation = Manifestation.new
      @manifestation.set_serial_number(@expression)
      @manifestation_forms = ManifestationForm.find(:all, :order => 'position')
      @languages = Language.find(:all, :order => 'position')
    end
  end

  # GET /manifestations/1;edit
  def edit
    @manifestation = Manifestation.find(params[:id])
    if params[:mode] == 'tag_edit'
      @bookmark = current_user.bookmarks.find(:first, :conditions => {:bookmarked_resource_id => @manifestation.bookmarked_resource.id}) rescue nil
      render :partial => 'tag_edit'
    end
    @manifestation_forms = ManifestationForm.find(:all, :order => 'position')
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
          flash[:notice] = ('Invalid ISBN.')
        when 'already imported'
          flash[:notice] = ('This manifestation is already imported.')
        else
          flash[:notice] = ('Record not found.')
        end
        redirect_to new_manifestation_url(:mode => 'import_isbn')
        return
      end
    else
      unless @expression
        flash[:notice] = ('Please specify expression id.')
        redirect_to expressions_url
        return
      end
      last_issue = @expression.last_issue
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
        flash[:notice] = ('Manifestation was successfully created.')
        #if params[:mode] == 'import_isbn'
        #  format.html { redirect_to edit_manifestation_url(@manifestation) }
        #  format.xml  { head :created, :location => manifestation_url(@manifestation) }
        #else
          unless @manifestation.patrons.blank?
            format.html { redirect_to manifestation_url(@manifestation) }
            format.xml  { head :created, :location => manifestation_url(@manifestation) }
          else
            format.html { redirect_to manifestation_patrons_url(@manifestation) }
            format.xml  { head :created, :location => manifestation_url(@manifestation) }
          end
        #end
      else
        @manifestation_forms = ManifestationForm.find(:all, :order => 'position')
        @languages = Language.find(:all, :order => 'position')
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
        flash[:notice] = ('Manifestation was successfully updated.')
        format.html { redirect_to manifestation_url(@manifestation) }
        format.xml  { head :ok }
      else
        @manifestation_forms = ManifestationForm.find(:all, :order => 'position')
        @languages = Language.find(:all, :order => 'position')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @manifestation.errors, :status => :unprocessable_entity }
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
    #if query.blank?
    #  if params[:advanced_search]
    #    query = "[* TO *]"
    #  end
    #end
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

    #unless options[:subject].blank?
    #  query = "#{query} subject: #{options[:subject]}"
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
      if number_of_pages['at_least'] == 0
        number_of_pages['at_least'] = "*"
      end
      if number_of_pages['at_most'] == 0
        number_of_pages['at_most'] = "*"
      end
      query = "#{query} number_of_pages: [#{number_of_pages['at_least']} TO #{number_of_pages['at_most']}]"
    end
    unless options[:pubdate_from].blank? and options[:pubdate_to].blank?
      pubdate = {}
      if options[:pubdate_from].blank?
        pubdate['from'] = "*"
      else
        pubdate['from'] = Time.mktime(options[:pubdate_from]).utc.iso8601
      end

      if options[:pubdate_to].blank?
        pubdate['to'] = "*"
      else
        pubdate['to'] = Time.mktime(options[:pubdate_to]).utc.iso8601
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
    when 'Expression'
      query = "#{query} expression_ids: #{object.id}"
    when 'Patron'
      query = "#{query} patron_ids: #{object.id}"
    when 'ManifestationForm'
      query = "#{query} formtype: #{object.name}"
    when 'Language'
      query = "#{query} lang: #{object.name}"
    when 'Subject'
      query = "#{query} subject_ids: #{object.id}"
    when 'Library'
      query = "#{query} library: #{object.short_name}"
    end
    return query
  end

  def get_facet(query)
    result = Manifestation.find_by_solr(query, {:facets => {:zeros => false, :fields => [:formtype_f, :library_f, :language_f, :subject_f]}})
    return result.facets["facet_fields"]
  rescue
    nil
  end

end
