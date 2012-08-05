class ItemRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @item_relationship_types = ItemRelationshipType.all
  end

  def index
    @item_relationships = ItemRelationship.page(params[:page])
  end

  def new
    @item_relationship = ItemRelationship.new(params[:item_relationship])
    @item_relationship.parent = Item.find(params[:item_id]) rescue nil
    @item_relationship.child = Item.find(params[:child_id]) rescue nil
  end
end
