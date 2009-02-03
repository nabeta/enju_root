class BookstoresController < ApplicationController
  before_filter :login_required
  require_role 'Librarian', :only => [:index, :show]
  require_role 'Administrator', :except => [:index, :show]

  # GET /bookstores
  # GET /bookstores.xml
  def index
    @bookstores = Bookstore.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookstores }
    end
  end

  # GET /bookstores/1
  # GET /bookstores/1.xml
  def show
    @bookstore = Bookstore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookstore }
    end
  end

  # GET /bookstores/new
  # GET /bookstores/new.xml
  def new
    @bookstore = Bookstore.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bookstore }
    end
  end

  # GET /bookstores/1/edit
  def edit
    @bookstore = Bookstore.find(params[:id])
  end

  # POST /bookstores
  # POST /bookstores.xml
  def create
    @bookstore = Bookstore.new(params[:bookstore])

    respond_to do |format|
      if @bookstore.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookstore'))
        format.html { redirect_to(@bookstore) }
        format.xml  { render :xml => @bookstore, :status => :created, :location => @bookstore }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookstore.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookstores/1
  # PUT /bookstores/1.xml
  def update
    @bookstore = Bookstore.find(params[:id])

    if @bookstore and params[:position]
      @bookstore.insert_at(params[:position])
      redirect_to bookstores_url
      return
    end

    respond_to do |format|
      if @bookstore.update_attributes(params[:bookstore])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookstore'))
        format.html { redirect_to(@bookstore) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookstore.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookstores/1
  # DELETE /bookstores/1.xml
  def destroy
    @bookstore = Bookstore.find(params[:id])
    @bookstore.destroy

    respond_to do |format|
      format.html { redirect_to(bookstores_url) }
      format.xml  { head :ok }
    end
  end
end
