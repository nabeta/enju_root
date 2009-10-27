class ContentTypesController < ApplicationController
  before_filter :has_permission?

  # GET /content_types
  # GET /content_types.xml
  def index
    @content_types = ContentType.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @content_types }
    end
  end

  # GET /content_types/1
  # GET /content_types/1.xml
  def show
    @content_type = ContentType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content_type }
    end
  end

  # GET /content_types/new
  # GET /content_types/new.xml
  def new
    @content_type = ContentType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content_type }
    end
  end

  # GET /content_types/1/edit
  def edit
    @content_type = ContentType.find(params[:id])
  end

  # POST /content_types
  # POST /content_types.xml
  def create
    @content_type = ContentType.new(params[:content_type])

    respond_to do |format|
      if @content_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.content_type'))
        format.html { redirect_to(@content_type) }
        format.xml  { render :xml => @content_type, :status => :created, :location => @content_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /content_types/1
  # PUT /content_types/1.xml
  def update
    @content_type = ContentType.find(params[:id])

    if @content_type and params[:position]
      @content_type.insert_at(params[:position])
      redirect_to content_types_url
      return
    end

    respond_to do |format|
      if @content_type.update_attributes(params[:content_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.content_type'))
        format.html { redirect_to(@content_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /content_types/1
  # DELETE /content_types/1.xml
  def destroy
    @content_type = ContentType.find(params[:id])
    @content_type.destroy

    respond_to do |format|
      format.html { redirect_to(content_types_url) }
      format.xml  { head :ok }
    end
  end
end
