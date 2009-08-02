class PurchaseRequestsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user_if_nil
  before_filter :get_order_list
  after_filter :convert_charset, :only => :index
  before_filter :store_page, :only => :index
 
  # GET /purchase_requests
  # GET /purchase_requests.xml
  def index
    begin
      if !current_user.has_role?('Librarian')
        raise unless current_user == @user
      end
    rescue
      access_denied; return
    end

    @count = {}
    PurchaseRequest.per_page = 65534 if params[:format] == 'csv'

    @query = params[:query].to_s.strip

    search = Sunspot.new_search(PurchaseRequest)
    search.query.keywords = @query if @query.present?
    search.query.add_restriction(:user_id, :equal_to, @user.id) if @user
    search.query.add_restriction(:order_list_id, :equal_to, @order_list.id) if @order_list
    case params[:mode]
    when 'not_ordered'
      search.query.add_restriction(:ordered, :equal_to, false)
    when 'ordered'
      search.query.add_restriction(:ordered, :equal_to, true)
    end

    #begin
      @purchase_requests = search.execute!.results
    #rescue
    #  @purchase_requests = WillPaginate::Collection.create(1,1,0) do end
    #end

    @count[:query_result] = @purchase_requests.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchase_requests }
      format.rss  { render :layout => false }
      format.atom
      format.csv
    end
  end

  # GET /purchase_requests/1
  # GET /purchase_requests/1.xml
  def show
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase_request }
    end
  end

  # GET /purchase_requests/new
  # GET /purchase_requests/new.xml
  def new
    begin
      if !current_user.has_role?('Librarian')
        raise unless current_user == @user
      end
    rescue
      access_denied; return
    end

    if @user
      @purchase_request = @user.purchase_requests.new
    else
      @purchase_request = PurchaseRequest.new
    end
    begin
      url = URI.parse(URI.encode(params[:url])).normalize.to_s
      title = Bookmark.get_title(params[:title])
      title = Bookmark.get_title_from_url(url) if title.nil?
    rescue
      url = nil
      title = nil
    end

    @purchase_request.url = url
    @purchase_request.title = title

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @purchase_request }
    end
  end

  # GET /purchase_requests/1/edit
  def edit
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end
  end

  # POST /purchase_requests
  # POST /purchase_requests.xml
  def create
    if @user
      @purchase_request = @user.purchase_requests.new(params[:purchase_request])
    else
      @purchase_request = current_user.purchase_requests.new(params[:purchase_request])
    end

    respond_to do |format|
      if @purchase_request.save
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.purchase_request'))
        format.html { redirect_to user_purchase_request_url(@purchase_request.user.login, @purchase_request) }
        format.xml  { render :xml => @purchase_request, :status => :created, :location => @purchase_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_requests/1
  # PUT /purchase_requests/1.xml
  def update
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end

    respond_to do |format|
      if @purchase_request.update_attributes(params[:purchase_request])
        @order_list.purchase_requests << @purchase_request if @order_list
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.purchase_request'))
        format.html { redirect_to user_purchase_request_url(@purchase_request.user.login, @purchase_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @purchase_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_requests/1
  # DELETE /purchase_requests/1.xml
  def destroy
    if @user
      @purchase_request = @user.purchase_requests.find(params[:id])
    else
      @purchase_request = PurchaseRequest.find(params[:id])
    end
    @purchase_request.destroy

    respond_to do |format|
      if current_user.has_role?('Librarian')
        format.html { redirect_to(purchase_requests_url) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(user_purchase_requests_url(@user.login)) }
        format.xml  { head :ok }
      end
    end
  end

end
