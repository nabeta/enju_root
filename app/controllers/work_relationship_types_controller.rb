class WorkRelationshipTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @work_relationship_type = WorkRelationshipType.find(params[:id])
    if params[:position]
      @work_relationship_type.insert_at(params[:position])
      redirect_to work_relationship_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.work_relationship_type')}
  end
end
