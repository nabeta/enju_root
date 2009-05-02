class NewsFeedsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :has_permission?
  cache_sweeper :news_feed_sweeper, :only => [:create, :update, :destroy]

  # GET /news_feeds
  # GET /news_feeds.xml
  def index
    @news_feeds = NewsFeed.paginate(:all, :order => :position, :page => params[:page])
    if params[:mode] == 'clear_cache'
      expire_fragment(:controller => :news_feeds, :action => :index, :action_suffix => 'list')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news_feeds }
    end
  end

  # GET /news_feeds/1
  # GET /news_feeds/1.xml
  def show
    @news_feed = NewsFeed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_feed }
    end
  end

  # GET /news_feeds/new
  # GET /news_feeds/new.xml
  def new
    @news_feed = NewsFeed.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_feed }
    end
  end

  # GET /news_feeds/1/edit
  def edit
    @news_feed = NewsFeed.find(params[:id])
  end

  # POST /news_feeds
  # POST /news_feeds.xml
  def create
    @news_feed = NewsFeed.new(params[:news_feed])

    respond_to do |format|
      if @news_feed.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.news_feed'))
        format.html { redirect_to(@news_feed) }
        format.xml  { render :xml => @news_feed, :status => :created, :location => @news_feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news_feeds/1
  # PUT /news_feeds/1.xml
  def update
    @news_feed = NewsFeed.find(params[:id])

    if @language and params[:position]
      @language.insert_at(params[:position])
      redirect_to languages_url
      return
    end
    if params[:mode] == 'force_reload'
      @news_feed.force_reload
    end

    respond_to do |format|
      if @news_feed.update_attributes(params[:news_feed])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.news_feed'))
        format.html { redirect_to(@news_feed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news_feeds/1
  # DELETE /news_feeds/1.xml
  def destroy
    @news_feed = NewsFeed.find(params[:id])
    @news_feed.destroy

    respond_to do |format|
      format.html { redirect_to(news_feeds_url) }
      format.xml  { head :ok }
    end
  end
end
