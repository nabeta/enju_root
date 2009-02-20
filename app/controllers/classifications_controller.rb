class ClassificationsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_subject
  require_role 'Administrator', :except => [:index, :show]

  # GET /classifications
  # GET /classifications.xml
  def index
    unless params[:query].blank?
      query = params[:query].to_s.strip
      @classifications = Classification.paginate_by_solr(query, :page => params[:page], :per_page => @per_page).compact
    else
      if @subject
        @classifications = @subject.classifications.paginate(:page => params[:page])
      else
        @classifications = Classification.paginate(:all, :page => params[:page])
      end
    end

    @query = params[:query]
    session[:params] = {} unless session[:params]
    session[:params][:classification] = params

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classifications }
    end
  end

  # GET /classifications/1
  # GET /classifications/1.xml
  def show
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classification }
    end
  end

  # GET /classifications/new
  # GET /classifications/new.xml
  def new
    @classification = Classification.new
    @classification_types = ClassificationType.find(:all, :order => :id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classification }
    end
  end

  # GET /classifications/1/edit
  def edit
    @classification = Classification.find(params[:id])
    @classification_types = ClassificationType.find(:all, :order => :id)
  end

  # POST /classifications
  # POST /classifications.xml
  def create
    @classification = Classification.new(params[:classification])

    respond_to do |format|
      if @classification.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.classification'))
        format.html { redirect_to(@classification) }
        format.xml  { render :xml => @classification, :status => :created, :location => @classification }
      else
        @classification_types = ClassificationType.find(:all, :order => :id)
        format.html { render :action => "new" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classifications/1
  # PUT /classifications/1.xml
  def update
    @classification = Classification.find(params[:id])

    respond_to do |format|
      if @classification.update_attributes(params[:classification])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.classification'))
        format.html { redirect_to(@classification) }
        format.xml  { head :ok }
      else
        @classification_types = ClassificationType.find(:all, :order => :id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classifications/1
  # DELETE /classifications/1.xml
  def destroy
    @classification = Classification.find(params[:id])
    @classification.destroy

    respond_to do |format|
      format.html { redirect_to(classifications_url) }
      format.xml  { head :ok }
    end
  end

end
