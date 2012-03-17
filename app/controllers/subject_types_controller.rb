class SubjectTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @subject_type = SubjectType.find(params[:id])
    if params[:move]
      move_position(@subject_type, params[:move])
      return
    end
    update!
  end
end
