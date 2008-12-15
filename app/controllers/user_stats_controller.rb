class UserStatsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]

  # GET /user_stats
  # GET /user_stats.xml
  def index
    @user_stats = UserStat.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_stats }
    end
  end

  # GET /user_stats/1
  # GET /user_stats/1.xml
  def show
    @user_stat = UserStat.find(params[:id])
    @stats = @user_stat.user_stat_has_checkouts.paginate(:all, :order => 'checkouts_count DESC, user_id', :page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_stat }
    end
  end

  # GET /user_stats/new
  # GET /user_stats/new.xml
  def new
    @user_stat = UserStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_stat }
    end
  end

  # GET /user_stats/1/edit
  def edit
    @user_stat = UserStat.find(params[:id])
  end

  # POST /user_stats
  # POST /user_stats.xml
  def create
    @user_stat = UserStat.new(params[:user_stat])

    respond_to do |format|
      if @user_stat.save
        flash[:notice] = 'UserStat was successfully created.'
        format.html { redirect_to(@user_stat) }
        format.xml  { render :xml => @user_stat, :status => :created, :location => @user_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_stats/1
  # PUT /user_stats/1.xml
  def update
    @user_stat = UserStat.find(params[:id])

    respond_to do |format|
      if @user_stat.update_attributes(params[:user_stat])
        flash[:notice] = 'UserStat was successfully updated.'
        format.html { redirect_to(@user_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_stats/1
  # DELETE /user_stats/1.xml
  def destroy
    @user_stat = UserStat.find(params[:id])
    @user_stat.destroy

    respond_to do |format|
      format.html { redirect_to(user_stats_url) }
      format.xml  { head :ok }
    end
  end
end
