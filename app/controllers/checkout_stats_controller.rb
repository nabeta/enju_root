class CheckoutStatsController < ApplicationController
  before_filter :login_required, :except => ['index', 'show']
  require_role 'Librarian', :except => ['index', 'show']

  # GET /checkout_stats
  # GET /checkout_stats.xml
  def index
    @checkout_stats = CheckoutStat.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkout_stats }
    end
  end

  # GET /checkout_stats/1
  # GET /checkout_stats/1.xml
  def show
    @checkout_stat = CheckoutStat.find(params[:id])
    @stats = @checkout_stat.checkout_stat_has_manifestations.find(:all, :order => 'checkouts_count DESC')

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checkout_stat }
    end
  end

  # GET /checkout_stats/new
  # GET /checkout_stats/new.xml
  def new
    @checkout_stat = CheckoutStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout_stat }
    end
  end

  # GET /checkout_stats/1/edit
  def edit
    @checkout_stat = CheckoutStat.find(params[:id])
  end

  # POST /checkout_stats
  # POST /checkout_stats.xml
  def create
    @checkout_stat = CheckoutStat.new(params[:checkout_stat])

    respond_to do |format|
      if @checkout_stat.save
        flash[:notice] = 'CheckoutStat was successfully created.'
        format.html { redirect_to(@checkout_stat) }
        format.xml  { render :xml => @checkout_stat, :status => :created, :location => @checkout_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_stats/1
  # PUT /checkout_stats/1.xml
  def update
    @checkout_stat = CheckoutStat.find(params[:id])

    respond_to do |format|
      if @checkout_stat.update_attributes(params[:checkout_stat])
        flash[:notice] = 'CheckoutStat was successfully updated.'
        format.html { redirect_to(@checkout_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_stats/1
  # DELETE /checkout_stats/1.xml
  def destroy
    @checkout_stat = CheckoutStat.find(params[:id])
    @checkout_stat.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_stats_url) }
      format.xml  { head :ok }
    end
  end
end
