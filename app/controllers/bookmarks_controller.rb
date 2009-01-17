class BookmarksController < ApplicationController
  #before_filter :login_required, :except => :new
  before_filter :login_required
  before_filter :authorized_content
  before_filter :get_user, :only => :new
  before_filter :get_user_if_nil, :except => :new
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  require_role 'Librarian', :only => [:index, :show, :edit]

  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    @bookmarks = Bookmark.paginate(:all, :page => params[:page], :per_page => @per_page, :order => ['id DESC'])
    
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
      url = URI.decode(params[:url])
      #parsed_url = URI.parse(URI.encode(url)).normalize
      #
      unless url.nil?
        if @bookmarked_resource = BookmarkedResource.find(:first, :conditions => {:url => url})
          if @bookmarked_resource.bookmarked?(current_user)
            flash[:notice] = ('This resource is already bookmarked.')
            redirect_to manifestation_url(@bookmarked_resource.manifestation)
            return
          end
          @title = @bookmarked_resource.title
        else
          @bookmarked_resource = BookmarkedResource.new(:url => url)
          @title = Bookmark.get_title(URI.encode(url))
        end
      else
        raise
      end
    rescue
      url = nil
      #parsed_url = nil
      flash[:notice] = ("Invalid URL.")
      redirect_to user_bookmarks_url(current_user.login)
      return
    end
    #unless parsed_url.nil?
      #if parsed_url.host == LIBRARY_WEB_HOSTNAME
      #  path = parsed_url.path.split('/')
      #  if path[1] == 'manifestations'
      #    manifestation = Manifestation.find(path[2]) rescue nil
      #    if manifestation.access_address
      #      access_url = manifestation.access_address
      #    end
      #  end
      #end
      #logger.debug "access_url: #{access_url}"
    #end
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

    Bookmark.transaction do
      unless url.blank?
        unless @bookmarked_resource = BookmarkedResource.find(:first, :conditions => {:url => url})
          @bookmarked_resource = BookmarkedResource.new(:url => url)
          if params[:bookmark][:title]
            @bookmarked_resource.title = params[:bookmark][:title]
          else
            @bookmarked_resource.title = Bookmark.get_title(URI.encode(url))
          end

          # 自館のページをブックマークする場合
          if URI.parse(url).host == LIBRARY_WEB_HOSTNAME
            path = URI.parse(url).path.split('/')
            if path[1] == 'manifestations' and Manifestation.find(path[2])
              @bookmarked_resource.manifestation = Manifestation.find(path[2]) rescue nil
            end
          end
        end

        unless @bookmarked_resource.manifestation
          @bookmarked_resource.manifestation = Manifestation.new(:original_title => @bookmarked_resource.title, :access_address => url)
          @bookmarked_resource.manifestation.manifestation_form = ManifestationForm.find(:first, :conditions => {:name => 'file'})
          #@bookmarked_resource.manifestation.save!
          work = Work.create!(:original_title => @bookmarked_resource.title)
          expression = Expression.new(:original_title => work.original_title)
          work.expressions << expression
        end
      else
        flash[:notice] = ('Specify title and url.')
        redirect_to new_user_bookmark_path(current_user.login)
        return
      end
    
      begin
        @bookmarked_resource.save!
        @bookmarked_resource.manifestation.expressions << expression if expression
      rescue
        flash[:notice] = ('Specify title and url.')
        redirect_to new_user_bookmark_path(current_user.login)
        return
      end

      if @user.bookmarks.find(:first, :conditions => {:bookmarked_resource_id => @bookmarked_resource.id})
        flash[:notice] = ('This resource is already bookmarked.')
        redirect_to new_user_bookmark_url(current_user.login)
        return
      end

      params[:bookmark][:user_id] = current_user.id
      @bookmark = Bookmark.new(params[:bookmark])
      @bookmark.bookmarked_resource = @bookmarked_resource

      @bookmarked_resource.manifestation.reload
    end

    respond_to do |format|
      if @bookmark.save!
        @bookmark.bookmarked_resource.manifestation.save!
        unless @bookmark.shelved?
          @bookmark.create_bookmark_item
        end
        flash[:notice] = ('Bookmark was successfully created.')
        if params[:tag_edit] == 'manifestation'
          format.html { redirect_to manifestation_url(@bookmarked_resource.manifestation) }
          format.xml  { head :ok }
        else
          format.html { redirect_to user_bookmarked_resource_url(@bookmark.user.login, @bookmark.bookmarked_resource) }
          format.xml  { head :created, :location => bookmark_url(@bookmark.user.login, @bookmark) }
        end
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
    @bookmark.title = @bookmark.bookmarked_resource.title

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = ('Bookmark was successfully updated.')
        @manifestation = @bookmark.bookmarked_resource.manifestation
        @manifestation.save
        if params[:tag_edit] == 'manifestation'
          format.html { redirect_to manifestation_url(@manifestation) }
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
      flash[:notice] = ('Bookmark was successfully deleted.')
    end

    if @user
      respond_to do |format|
        format.html { redirect_to user_bookmarks_url(@user.login) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to bookmarks_url }
        format.xml  { head :ok }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def authorized_content
    @user = get_user_if_nil
    if logged_in?
      if current_user.has_role?('Librarian')
        if @user
          user = @user
        else
          user = current_user
        end
      else
        user = current_user
      end
    end
    
    if user.nil?
      access_denied
      return
    end

    unless current_user.has_role?('Librarian')
      access_denied unless user == @user
      return
    end

  end

end
