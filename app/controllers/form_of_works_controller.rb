class FormOfWorksController < InheritedResources::Base
  respond_to :html, :json
  has_scope :page, :default => 1
  load_and_authorize_resource

  def update
    @form_of_work = FormOfWork.find(params[:id])
    if params[:move]
      move_position(@form_of_work, params[:move])
      return
    end
    update!
  end
end
