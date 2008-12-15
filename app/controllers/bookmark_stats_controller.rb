class BookmarkStatsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]

  # GET /bookmark_stats
  # GET /bookmark_stats.xml
  def index
    @bookmark_stats = BookmarkStat.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmark_stats }
    end
  end

  # GET /bookmark_stats/1
  # GET /bookmark_stats/1.xml
  def show
    @bookmark_stat = BookmarkStat.find(params[:id])
    @stats = @bookmark_stat.bookmark_stat_has_manifestations.paginate(:all, :order => 'bookmarks_count DESC, manifestation_id', :page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookmark_stat }
    end
  end

  # GET /bookmark_stats/new
  # GET /bookmark_stats/new.xml
  def new
    @bookmark_stat = BookmarkStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bookmark_stat }
    end
  end

  # GET /bookmark_stats/1/edit
  def edit
    @bookmark_stat = BookmarkStat.find(params[:id])
  end

  # POST /bookmark_stats
  # POST /bookmark_stats.xml
  def create
    @bookmark_stat = BookmarkStat.new(params[:bookmark_stat])

    respond_to do |format|
      if @bookmark_stat.save
        flash[:notice] = 'BookmarkStat was successfully created.'
        format.html { redirect_to(@bookmark_stat) }
        format.xml  { render :xml => @bookmark_stat, :status => :created, :location => @bookmark_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookmark_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookmark_stats/1
  # PUT /bookmark_stats/1.xml
  def update
    @bookmark_stat = BookmarkStat.find(params[:id])

    respond_to do |format|
      if @bookmark_stat.update_attributes(params[:bookmark_stat])
        flash[:notice] = 'BookmarkStat was successfully updated.'
        format.html { redirect_to(@bookmark_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmark_stats/1
  # DELETE /bookmark_stats/1.xml
  def destroy
    @bookmark_stat = BookmarkStat.find(params[:id])
    @bookmark_stat.destroy

    respond_to do |format|
      format.html { redirect_to(bookmark_stats_url) }
      format.xml  { head :ok }
    end
  end
end
