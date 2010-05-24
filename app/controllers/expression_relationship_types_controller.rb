class ExpressionRelationshipTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @expression_relationship_type = ExpressionRelationshipType.find(params[:id])
    if params[:position]
      @expression_relationship_type.insert_at(params[:position])
      redirect_to expression_relationship_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.expression_relationship_type')}
  end
end
