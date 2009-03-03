class NewsPostsController < ApplicationController
  before_filter :has_permission?

  # GET /news_posts
  # GET /news_posts.xml
  def index
    @news_posts = NewsPost.published.paginate(:all, :order => :position, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news_posts }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /news_posts/1
  # GET /news_posts/1.xml
  def show
    @news_post = NewsPost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_post }
    end
  end

  # GET /news_posts/new
  # GET /news_posts/new.xml
  def new
    @news_post = NewsPost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_post }
    end
  end

  # GET /news_posts/1/edit
  def edit
    @news_post = NewsPost.find(params[:id])
  end

  # POST /news_posts
  # POST /news_posts.xml
  def create
    @news_post = NewsPost.new(params[:news_post])
    @news_post.user = current_user

    respond_to do |format|
      if @news_post.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.news_post'))
        format.html { redirect_to(@news_post) }
        format.xml  { render :xml => @news_post, :status => :created, :location => @news_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news_posts/1
  # PUT /news_posts/1.xml
  def update
    @news_post = NewsPost.find(params[:id])

    respond_to do |format|
      if @news_post.update_attributes(params[:news_post])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.news_post'))
        format.html { redirect_to(@news_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news_posts/1
  # DELETE /news_posts/1.xml
  def destroy
    @news_post = NewsPost.find(params[:id])
    @news_post.destroy

    respond_to do |format|
      format.html { redirect_to(news_posts_url) }
      format.xml  { head :ok }
    end
  end
end
