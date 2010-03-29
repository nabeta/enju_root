# -*- encoding: utf-8 -*-
class BookmarksController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user, :only => :new
  before_filter :get_user_if_nil, :except => :new
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    if logged_in?
      begin
        if !current_user.has_role?('Librarian')
          raise unless @user.share_bookmarks?
        end
      rescue
        if @user
          unless current_user == @user
            access_denied; return
          end
        else
          redirect_to user_bookmarks_path(current_user.login)
          return
        end
      end
    end

    search = Sunspot.new_search(Bookmark)
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
    end
    user = @user
    search.build do
      fulltext query
      order_by(:created_at, :desc)
      with(:user_id).equal_to user.id if user
    end
    page = params[:page] || 1
    search.query.paginate(page.to_i, Bookmark.per_page)
    #@bookmarks = @user.bookmarks.paginate(:all, :page => params[:page], :order => ['id DESC'])
    @bookmarks = search.execute!.results
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @bookmarks }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to bookmarks_url
    return
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
  end

  # GET /bookmarks/new
  def new
    unless current_user == @user
      access_denied
      return
    end
    @bookmark = Bookmark.new(params[:bookmark])
    begin
      url = URI.parse(URI.encode(params[:url])).normalize.to_s
      if url
        @bookmark.url = url
        if @manifestation = @bookmark.check_url
          if @manifestation.bookmarked?(current_user)
            raise 'already_bookmarked'
          end
          @bookmark.title = @manifestation.original_title
        else
          @bookmark.title = Bookmark.get_title(params[:title])
          @bookmark.title = Bookmark.get_title_from_url(url) if @bookmark.title.nil?
        end
      else
        raise 'invalid_url'
      end
    rescue
      logger.warn "Failed to bookmark: #{url}"
      case $!.to_s
      when 'invalid_url'
        flash[:notice] = t('bookmark.invalid_url')
      when 'only_manifestation_should_be_bookmarked'
        flash[:notice] = t('bookmark.only_manifestation_should_be_bookmarked')
        redirect_to @bookmark.url
      when 'already_bookmarked'
        flash[:notice] = t('bookmark.already_bookmarked')
        redirect_to manifestation_url(@manifestation)
        return
      # OTC start
      # 自館のページではない場合、メッセージを表示して空のページを表示
      when 'not_our_holding'
        flash[:notice] = t('bookmark.not_our_holding')
        redirect_to new_user_bookmark_url(current_user.login)
      # OTC end
      end
    end
  end
  
  # GET /bookmarks/1;edit
  def edit
    if @user
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = current_user.bookmarks.new(params[:bookmark])
    @bookmark.tag_list = params[:bookmark][:tag_list]

    respond_to do |format|
      begin
        if @bookmark.save
          flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookmark'))
          if params[:mode] == 'tag_edit'
            format.html { redirect_to manifestation_url(@bookmark.manifestation) }
            format.xml  { render :xml => @bookmark, :status => :created, :location => user_bookmark_url(@bookmark.user.login, @bookmark) }
          else
            format.html { redirect_to(@bookmark) }
            format.xml  { render :xml => @bookmark, :status => :created, :location => user_bookmark_url(@bookmark.user.login, @bookmark) }
          end
        else
          @user = current_user
          format.html { render :action => "new" }
          format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
        end
      rescue
        case $!.to_s
        when 'already_bookmarked'
          flash[:notice] = t('bookmark.already_bookmarked')
        when 'invalid_url'
          flash[:notice] = t('bookmark.invalid_url')
        when 'specify_title_and_url'
          flash[:notice] = t('bookmark.specify_title_and_url')
        # OTC start
        # 指定したurlが自館のサイトでない場合
        when 'not_our_holding'
          flash[:notice] = t('bookmark.not_our_holding')
        # OTC end
        end
        format.html { redirect_to new_user_bookmark_url(current_user.login) }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end

    session[:params][:bookmark] = nil if session[:params]
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
    @bookmark.title = @bookmark.manifestation.try(:original_title)
    if params[:mode] == 'remove_tag'
      tag = Tag.find(params[:name])
      @bookmark.tags -= Tag.find(:all, :conditions => {:name => tag.name})
    else
      @bookmark.tag_list = params[:bookmark][:tag_list]
    end

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookmark'))
        @bookmark.manifestation.save
        case params[:mode]
        when 'remove_tag'
          format.html { redirect_to manifestation_url(@bookmark.manifestation) }
          format.xml  { head :ok }
        when 'tag_edit'
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
  end

end
