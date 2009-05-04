class LanguagesController < ApplicationController
  before_filter :has_permission?

  # GET /languages
  # GET /languages.xml
  def index
    @languages = Rails.cache.fetch('Language.all'){Language.all}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @languages }
    end
  end

  # GET /languages/1
  # GET /languages/1.xml
  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @language }
    end
  end

  # GET /languages/new
  # GET /languages/new.xml
  def new
    @language = Language.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @language }
    end
  end

  # GET /languages/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  # POST /languages
  # POST /languages.xml
  def create
    @language = Language.new(params[:language])

    respond_to do |format|
      if @language.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.language'))
        format.html { redirect_to(@language) }
        format.xml  { render :xml => @language, :status => :created, :location => @language }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /languages/1
  # PUT /languages/1.xml
  def update
    @language = Language.find(params[:id])

    if @language and params[:position]
      @language.insert_at(params[:position])
      redirect_to languages_url
      return
    end

    respond_to do |format|
      if @language.update_attributes(params[:language])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.language'))
        format.html { redirect_to(@language) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.xml
  def destroy
    @language = Language.find(params[:id])
    @language.destroy

    respond_to do |format|
      format.html { redirect_to(languages_url) }
      format.xml  { head :ok }
    end
  end
end
