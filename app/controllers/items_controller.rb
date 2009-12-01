# -*- encoding: utf-8 -*-
class ItemsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user_if_nil
  before_filter :get_patron, :only => [:index]
  before_filter :get_manifestation, :get_inventory_file
  before_filter :get_shelf, :only => [:index]
  before_filter :get_library, :only => [:new]
  before_filter :get_item, :only => :index
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_version, :only => [:show]
  #before_filter :store_location
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /items
  # GET /items.xml
  def index
    query = params[:query].to_s.strip
    @count = {}
    if logged_in?
      if current_user.has_role?('Librarian')
        if params[:format] == 'csv'
          Item.per_page = 65534
        elsif params[:mode] == 'barcode'
          Item.per_page = 40
        end
      end
    end

    if @inventory_file
      if logged_in?
        if current_user.has_role?('Librarian')
          case params[:inventory]
          when 'not_on_shelf'
            mode = 'not_on_shelf'
          when 'not_in_catalog'
            mode = 'not_in_catalog'
          end
          order = 'id'
          @items = Item.inventory_items(@inventory_file, mode).paginate(:page => params[:page], :order => order) rescue [].paginate
        else
          access_denied
          return
        end
      else
        redirect_to new_user_session_url
        return
      end
    else
      search = Sunspot.new_search(Item)
      set_role_query(current_user, search)

      @query = query.dup
      unless query.blank?
        search.build do
          fulltext query
        end
      end

      patron = @patron
      manifestation = @manifestation
      shelf = @shelf
      unless params[:mode] == 'add'
        search.build do
          with(:patron_ids).equal_to patron.id if patron
          with(:manifestation_id).equal_to manifestation.id if manifestation
          with(:shelf_id).equal_to shelf.id if shelf
        end
      end

      search.build do
        order_by(:created_at, :desc)
      end

      page = params[:page] || 1
      search.query.paginate(page.to_i, Item.per_page)
      begin
        @items = search.execute!.results
        @count[:total] = @items.total_entries
      rescue
        @items = WillPaginate::Collection.create(1,1,0) do end
        @count[:total] = 0
      end
    end

    if params[:mode] == 'barcode'
      render :action => 'barcode', :layout => false
      return
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @items }
      format.csv  { render :layout => false }
      format.atom
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])
    @item.revert_to(@version) if @version

    canonical_url item_url(@item)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @item }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /items/new
  def new
    if @shelves.blank?
      flash[:notice] = t('item.create_shelf_first')
      redirect_to libraries_url
      return
    end
    unless @manifestation
      flash[:notice] = t('item.specify_manifestation')
      redirect_to manifestations_url
      return
    end
    @item = Item.new
    @item.manifestation = @manifestation
    @circulation_statuses = CirculationStatus.find(:all, :conditions => {:name => ['In Process', 'Available For Pickup', 'Available On Shelf', 'Claimed Returned Or Never Borrowed', 'Not Available']}, :order => :position)
    @item.circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'In Process'})
    @item.checkout_type = @manifestation.carrier_type.checkout_types.first

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1;edit
  def edit
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])
    unless @manifestation
      flash[:notice] = t('item.specify_manifestation')
      redirect_to manifestations_url
      return
    end
    @item.manifestation = @manifestation
    @item.item_identifier = @item.item_identifier.to_s.strip
    @item.creator = current_user

    respond_to do |format|
      if @item.save
        Item.transaction do
          @item.reload

          if @item.shelf
            @item.shelf.library.patron.items << @item
          end
          if @item.reserved?
            #ReservationNotifier.deliver_reserved(@item.manifestation.next_reservation.user)
            flash[:message] = t('item.this_item_is_reserved')
            @item.retain(current_user)
          end
        end
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.item'))
        @item.send_later(:post_to_union_catalog) if LibraryGroup.site_config.post_to_union_catalog
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        if @item.shelf
          #if @item.owns.blank?
          #  @item.owns.create(:patron_id => @item.shelf.library.patron_id)
          #else
          #  @item.owns.find(:first).update_attribute(:patron_id, @item.shelf.library.patron_id)
          #end
        end
        use_restrictions = UseRestriction.find(:all, :conditions => ['id IN (?)', params[:use_restriction_id]])
        ItemHasUseRestriction.delete_all(['item_id = ?', @item.id])
        @item.use_restrictions << use_restrictions
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.item'))
        format.html { redirect_to item_url(@item) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      if @item.manifestation
        format.html { redirect_to manifestation_items_url(@item.manifestation) }
        format.xml  { head :ok }
      else
        format.html { redirect_to items_url }
        format.xml  { head :ok }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private
  def prepare_options
    @libraries = Library.all
    @library = Library.find(:first, :order => :position, :include => :shelves) if @library.blank?
    @shelves = Shelf.find(:all, :order => :position)
    @circulation_statuses = CirculationStatus.find(:all)
    @bookstores = Bookstore.find(:all, :order => :position)
    @use_restrictions = UseRestriction.find(:all)
    if @manifestation
      @checkout_types = CheckoutType.available_for_carrier_type(@manifestation.carrier_type)
    else
      @checkout_types = CheckoutType.find(:all)
    end
  end

end
