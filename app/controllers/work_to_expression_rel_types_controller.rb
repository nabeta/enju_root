class WorkToExpressionRelTypesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @work_to_expression_rel_type = WorkToExpressionRelType.find(params[:id])
    if params[:position]
      @work_to_expression_rel_type.insert_at(params[:position])
      redirect_to work_to_expression_rel_types_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.work_to_expression_rel_type')}
  end
end
