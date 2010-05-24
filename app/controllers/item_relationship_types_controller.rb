class ItemRelationshipTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @item_relationship_type = ItemRelationshipType.find(params[:id])
    if params[:position]
      @item_relationship_type.insert_at(params[:position])
      redirect_to item_relationship_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.item_relationship_type')}
  end
end
