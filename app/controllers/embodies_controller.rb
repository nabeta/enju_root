class EmbodiesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_manifestation, :get_expression
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  #cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /embodies
  # GET /embodies.json
  def index
    case 
    when @manifestation
      @embodies = @manifestation.embodies.order('embodies.id').page(params[:page])
    when @expression
      @embodies = @expression.embodies.order('embodies.id').page(params[:page])
    else
      @embodies = Embody.order(:id).page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @embodies }
    end
  end

  # GET /embodies/1
  # GET /embodies/1.json
  def show
    @embody = Embody.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @embody }
    end
  end

  # GET /embodies/new
  # GET /embodies/new.json
  def new
    @embody = Embody.new
    @embody.expression = @expression
    @embody.manifestation = @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @embody }
    end
  end

  # GET /embodies/1/edit
  def edit
    @embody = Embody.find(params[:id])
  end

  # POST /embodies
  # POST /embodies.json
  def create
    @embody = Embody.new(params[:embody])

    respond_to do |format|
      if @embody.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.embody'))
        format.html { redirect_to(@embody) }
        format.json { render :json => @embody, :status => :created, :location => @embody }
      else
        format.html { render :action => "new" }
        format.json { render :json => @embody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /embodies/1
  # PUT /embodies/1.json
  def update
    @embody = Embody.find(params[:id])

    respond_to do |format|
      if @embody.update_attributes(params[:embody])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.embody'))
        format.html { redirect_to(@embody) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @embody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /embodies/1
  # DELETE /embodies/1.json
  def destroy
    @embody = Embody.find(params[:id])
    @embody.destroy

    respond_to do |format|
      format.html { redirect_to(embodies_url) }
      format.json { head :no_content }
    end
  end

end
