class ReserveStatsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]

  # GET /reserve_stats
  # GET /reserve_stats.xml
  def index
    @reserve_stats = ReserveStat.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reserve_stats }
    end
  end

  # GET /reserve_stats/1
  # GET /reserve_stats/1.xml
  def show
    @reserve_stat = ReserveStat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reserve_stat }
    end
  end

  # GET /reserve_stats/new
  # GET /reserve_stats/new.xml
  def new
    @reserve_stat = ReserveStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reserve_stat }
    end
  end

  # GET /reserve_stats/1/edit
  def edit
    @reserve_stat = ReserveStat.find(params[:id])
  end

  # POST /reserve_stats
  # POST /reserve_stats.xml
  def create
    @reserve_stat = ReserveStat.new(params[:reserve_stat])

    respond_to do |format|
      if @reserve_stat.save
        flash[:notice] = 'ReserveStat was successfully created.'
        format.html { redirect_to(@reserve_stat) }
        format.xml  { render :xml => @reserve_stat, :status => :created, :location => @reserve_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserve_stats/1
  # PUT /reserve_stats/1.xml
  def update
    @reserve_stat = ReserveStat.find(params[:id])

    respond_to do |format|
      if @reserve_stat.update_attributes(params[:reserve_stat])
        flash[:notice] = 'ReserveStat was successfully updated.'
        format.html { redirect_to(@reserve_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserve_stats/1
  # DELETE /reserve_stats/1.xml
  def destroy
    @reserve_stat = ReserveStat.find(params[:id])
    @reserve_stat.destroy

    respond_to do |format|
      format.html { redirect_to(reserve_stats_url) }
      format.xml  { head :ok }
    end
  end
end
