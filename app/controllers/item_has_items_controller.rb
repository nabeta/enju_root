class ItemHasItemsController < ApplicationController
  before_filter :has_permission?

  # GET /item_has_items
  # GET /item_has_items.xml
  def index
    @item_has_items = ItemHasItem.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_has_items }
    end
  end

  # GET /item_has_items/1
  # GET /item_has_items/1.xml
  def show
    @item_has_item = ItemHasItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_has_item }
    end
  end

  # GET /item_has_items/new
  # GET /item_has_items/new.xml
  def new
    @item_has_item = ItemHasItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_has_item }
    end
  end

  # GET /item_has_items/1/edit
  def edit
    @item_has_item = ItemHasItem.find(params[:id])
  end

  # POST /item_has_items
  # POST /item_has_items.xml
  def create
    @item_has_item = ItemHasItem.new(params[:item_has_item])

    respond_to do |format|
      if @item_has_item.save
        flash[:notice] = 'ItemHasItem was successfully created.'
        format.html { redirect_to(@item_has_item) }
        format.xml  { render :xml => @item_has_item, :status => :created, :location => @item_has_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_has_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_has_items/1
  # PUT /item_has_items/1.xml
  def update
    @item_has_item = ItemHasItem.find(params[:id])

    respond_to do |format|
      if @item_has_item.update_attributes(params[:item_has_item])
        flash[:notice] = 'ItemHasItem was successfully updated.'
        format.html { redirect_to(@item_has_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_has_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_has_items/1
  # DELETE /item_has_items/1.xml
  def destroy
    @item_has_item = ItemHasItem.find(params[:id])
    @item_has_item.destroy

    respond_to do |format|
      format.html { redirect_to(item_has_items_url) }
      format.xml  { head :ok }
    end
  end
end
