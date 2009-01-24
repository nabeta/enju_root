class CheckedItemsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :login_required
  before_filter :get_basket
  require_role 'Librarian'

  # GET /checked_items
  # GET /checked_items.xml
  def index
    if @basket
      @checked_items = @basket.checked_items.find(:all)
      @checked_item = @basket.checked_items.new
    else
      access_denied
      return
    end

    if params[:mode] == 'list'
      render :partial => 'list'
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checked_items }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /checked_items/1
  # GET /checked_items/1.xml
  def show
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checked_item }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /checked_items/new
  # GET /checked_items/new.xml
  def new
    if @basket
      @checked_item = @basket.checked_items.new
    else
      access_denied
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checked_item }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # GET /checked_items/1/edit
  def edit
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # POST /checked_items
  # POST /checked_items.xml
  def create
    if @basket
      @checked_item = CheckedItem.new(params[:checked_item])
      @checked_item.basket = @basket
    else
      access_denied
      return
    end

    flash[:message] = []
    item_identifier = @checked_item.item_identifier.to_s.strip
    unless item_identifier.blank?
      #item = Item.find(:first, :conditions => {:item_identifier => item_identifier})
      item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ? LIMIT 1', item_identifier]).first
    end

    if item.blank?
      flash[:message] << ('Item not found.')
      raise ActiveRecord::RecordNotFound
    end

    unless item.available_for_checkout?
      flash[:message] << ('This item is not available for check out.')
      raise
    end

    @checked_item.item = item unless item.blank?
    unless @checked_item.check_item_status.blank?
      flash[:message] += @checked_item.check_item_status
      raise ActiveRecord::RecordNotFound
    end

    respond_to do |format|
      if @checked_item.save
        flash[:message] << @checked_item.check_item_status
        if @checked_item.item.reserved?
          flash[:message] << ('This item is reserved!')
          if @checked_item.item.manifestation.reserved?(@basket.user)
            reserve = Reserve.find(:first, :conditions => {:user_id => @basket.user.id, :manifestation_id => @checked_item.item.manifestation.id})
            reserve.destroy
          end
        end

        if @checked_item.item.include_supplements
          flash[:message] << ('This item include supplements.')
        end
        flash[:notice] = ('CheckedItem was successfully created.')

        if params[:mode] == 'list'
          redirect_to(user_basket_checked_items_url(@basket.user.login, @basket, :mode => 'list'))
          return
        else
          format.html { redirect_to(user_basket_checked_items_url(@basket.user.login, @basket)) }
          format.xml  { render :xml => @checked_item, :status => :created, :location => @checked_item }
        end
      else
        if params[:mode] == 'list'
          redirect_to(user_basket_checked_items_url(@basket.user.login, @basket, :mode => 'list'))
          return
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @checked_item.errors, :status => :unprocessable_entity }
        end
      end
    end
  rescue
    #not_found
    if @basket
      if params[:mode] == 'list'
        redirect_to(user_basket_checked_items_url(@basket.user.login, @basket, :mode => 'list'))
      else
        redirect_to user_basket_checked_items_url(@basket.user.login, @basket)
      end
    else
      redirect_to new_basket_url
    end
  end

  # PUT /checked_items/1
  # PUT /checked_items/1.xml
  def update
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end

    respond_to do |format|
      if @checked_item.update_attributes(params[:checked_item])
        flash[:notice] = ('CheckedItem was successfully updated.')
        format.html { redirect_to(@checked_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checked_item.errors, :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /checked_items/1
  # DELETE /checked_items/1.xml
  def destroy
    if @basket
      @checked_item = @basket.checked_items.find(params[:id])
    else
      access_denied
      return
    end
    @checked_item.destroy

    respond_to do |format|
      format.html { redirect_to(user_basket_checked_items_url(@checked_item.basket.user.login, @checked_item.basket)) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private
  def validate_checked_item
  end
end
