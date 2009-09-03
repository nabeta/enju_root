class BookmarksController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user, :only => :new
  before_filter :get_user_if_nil, :except => :new
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]


  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    if logged_in?
      begin
        if !current_user.has_role?('Librarian')
          raise unless @user.share_bookmarks? or current_user == @user
        end
      rescue
        access_denied; return
      end
    end

    if @user
      @bookmarks = @user.bookmarks.paginate(:all, :page => params[:page], :order => ['id DESC'])
    else
      @bookmarks = Bookmark.paginate(:all, :page => params[:page], :order => ['id DESC'])
    end
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @bookmarks }
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.xml
  def show
    if @user
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @bookmark }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /bookmarks/new
  def new
    unless current_user == @user
      access_denied
      return
    end
    begin
      #url = URI.decode(params[:url])
      url = URI.parse(URI.encode(params[:url])).normalize.to_s
      unless url.nil?
        if @manifestation = Manifestation.find(:first, :conditions => {:access_address => url})
          if @manifestation.bookmarked?(current_user)
            flash[:notice] = t('bookmark.already_bookmarked')
            redirect_to manifestation_url(@manifestation)
            return
          end
          @title = @manifestation.original_title
        else
          @manifestation = Manifestation.new(:access_address => url)
          #@title = Bookmark.get_title(URI.encode(url), root_url)
          #@title = Bookmark.get_title(url, root_url)
          @title = Bookmark.get_title(params[:title])
          @title = Bookmark.get_title_from_url(url) if @title.nil?
        end
      else
        raise
      end
    rescue
      flash[:notice] = t('bookmark.invalid_url')
      redirect_to new_user_bookmark_url(current_user.login)
      logger.warn "Failed to bookmark: #{url}"
      #redirect_to user_bookmarks_url(current_user.login)
      #return
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end
  
  # GET /bookmarks/1;edit
  def edit
    if @user
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    url = URI.parse(params[:bookmark][:url]).normalize.to_s rescue nil
    url = "" if url == "/"
    if url.nil?
      flash[:notice] = t('bookmark.invalid_url')
      redirect_to new_user_bookmark_url(current_user.login)
      return
    end
    @bookmark = current_user.bookmarks.new(params[:bookmark])

    # 自館のページをブックマークする場合
    if URI.parse(url).host == LIBRARY_WEB_HOSTNAME
      path = URI.parse(url).path.split('/')
      if path[1] == 'manifestations' and Manifestation.find(path[2])
        @manifestation = Manifestation.find(path[2])
      end
    else
      @manifestation = Manifestation.find(:first, :conditions => {:access_address => url}) if url.present?
    end

    if @manifestation
      if @manifestation.bookmarked?(current_user)
        flash[:notice] = t('bookmark.already_bookmarked')
        redirect_to new_user_bookmark_url(current_user.login)
        return
      end
    else
      @manifestation = Manifestation.new(:access_address => url)
      @manifestation.carrier_type = CarrierType.find(:first, :conditions => {:name => 'file'})
      if @bookmark.title.present?
        @manifestation.original_title = @bookmark.title
      else
        @manifestation.original_title = Bookmark.get_title_from_url(url)
      end

      Bookmark.transaction do
        @manifestation.save
        begin
          work = Work.create!(:original_title => @manifestation.original_title)
          expression = Expression.new(:original_title => work.original_title)
          work.expressions << expression
          @manifestation.expressions << expression
        rescue
          flash[:notice] = t('bookmark.specify_title_and_url')
          redirect_to new_user_bookmark_path(current_user.login)
          return
        end
      end
    end

    @bookmark.manifestation = @manifestation

    respond_to do |format|
      if @bookmark.save!
        unless @bookmark.shelved?
          @bookmark.create_bookmark_item
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookmark'))
        #if params[:tag_edit] == 'manifestation'
        #  format.html { redirect_to manifestation_url(@bookmark.manifestation) }
        #  format.xml  { head :ok }
        #else
          format.html { redirect_to manifestation_url(@bookmark.manifestation) }
          format.xml  { render :xml => @bookmark, :status => :created, :location => user_bookmark_url(@bookmark.user.login, @bookmark) }
        #end
      else
        respond_to do |format|
          @user = User.find(:first, :conditions => {:login => params[:user_id]})
          format.html { render :action => "new" }
          format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
        end
      end
    end

    session[:params][:bookmark] = nil if session[:params]
  #rescue ActiveRecord::RecordNotFound
  #  not_found
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    if @user
      params[:bookmark][:user_id] = @user.id
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
    @bookmark.title = @bookmark.manifestation.original_title

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookmark'))
        @bookmark.manifestation.save
        if params[:tag_edit] == 'manifestation'
          format.html { redirect_to manifestation_url(@bookmark.manifestation) }
          format.xml  { head :ok }
        else
          format.html { redirect_to user_bookmark_url(@bookmark.user.login, @bookmark) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    if @user
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
    
    if @bookmark.user == @user
      @bookmark.destroy
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.bookmark'))
    end

    if @user
      respond_to do |format|
        format.html { redirect_to user_bookmarks_url(@user.login) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_bookmarks_url(current_user.login) }
        format.xml  { head :ok }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

end
