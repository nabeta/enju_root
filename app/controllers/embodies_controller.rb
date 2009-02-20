class EmbodiesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :except => [:index, :show]
  before_filter :get_manifestation, :get_expression
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /embodies
  # GET /embodies.xml
  def index
    case 
    when @manifestation
      @embodies = @manifestation.embodies.paginate(:page => params[:page], :order => ['embodies.id'])
    when @expression
      @embodies = @expression.embodies.paginate(:page => params[:page], :order => ['embodies.id'])
    else
      @embodies = Embody.paginate(:all, :page => params[:page], :order => :id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @embodies }
    end
  end

  # GET /embodies/1
  # GET /embodies/1.xml
  def show
    @embody = Embody.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @embody }
    end
  end

  # GET /embodies/new
  # GET /embodies/new.xml
  def new
    @embody = Embody.new
    @embody.expression = @expression
    @embody.manifestation = @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @embody }
    end
  end

  # GET /embodies/1/edit
  def edit
    @embody = Embody.find(params[:id])
  end

  # POST /embodies
  # POST /embodies.xml
  def create
    @embody = Embody.new(params[:embody])

    respond_to do |format|
      if @embody.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.embody'))
        format.html { redirect_to(@embody) }
        format.xml  { render :xml => @embody, :status => :created, :location => @embody }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @embody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /embodies/1
  # PUT /embodies/1.xml
  def update
    @embody = Embody.find(params[:id])

    respond_to do |format|
      if @embody.update_attributes(params[:embody])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.embody'))
        format.html { redirect_to(@embody) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @embody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /embodies/1
  # DELETE /embodies/1.xml
  def destroy
    @embody = Embody.find(params[:id])
    @embody.destroy

    respond_to do |format|
      format.html { redirect_to(embodies_url) }
      format.xml  { head :ok }
    end
  end
end
