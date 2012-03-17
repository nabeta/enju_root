class ClassificationTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @classification_type = ClassificationType.find(params[:id])
    if params[:move]
      move_position(@classification_type, params[:move])
      return
    end
    update!
  end
end
