class ItemRelationshipTypesController < ApplicationController
  before_filter :has_permission?

  # GET /item_relationship_types
  # GET /item_relationship_types.xml
  def index
    @item_relationship_types = ItemRelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_relationship_types }
    end
  end

  # GET /item_relationship_types/1
  # GET /item_relationship_types/1.xml
  def show
    @item_relationship_type = ItemRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_relationship_type }
    end
  end

  # GET /item_relationship_types/new
  # GET /item_relationship_types/new.xml
  def new
    @item_relationship_type = ItemRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_relationship_type }
    end
  end

  # GET /item_relationship_types/1/edit
  def edit
    @item_relationship_type = ItemRelationshipType.find(params[:id])
  end

  # POST /item_relationship_types
  # POST /item_relationship_types.xml
  def create
    @item_relationship_type = ItemRelationshipType.new(params[:item_relationship_type])

    respond_to do |format|
      if @item_relationship_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.item_relationship_type'))
        format.html { redirect_to(@item_relationship_type) }
        format.xml  { render :xml => @item_relationship_type, :status => :created, :location => @item_relationship_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_relationship_types/1
  # PUT /item_relationship_types/1.xml
  def update
    @item_relationship_type = ItemRelationshipType.find(params[:id])

    if @item_relationship_type and params[:position]
      @item_relationship_type.insert_at(params[:position])
      redirect_to item_relationship_types_url
      return
    end

    respond_to do |format|
      if @item_relationship_type.update_attributes(params[:item_relationship_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.item_relationship_type'))
        format.html { redirect_to(@item_relationship_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_relationship_types/1
  # DELETE /item_relationship_types/1.xml
  def destroy
    @item_relationship_type = ItemRelationshipType.find(params[:id])
    @item_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(item_relationship_types_url) }
      format.xml  { head :ok }
    end
  end
end
