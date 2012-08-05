class EventImportResultsController < InheritedResources::Base
  respond_to :html, :json, :csv
  load_and_authorize_resource
  has_scope :file_id
  actions :index, :show, :destroy

  def index
    @event_import_file = EventImportFile.where(:id => params[:event_import_file_id]).first
    if @event_import_file
      @event_import_results = @event_import_file.event_import_results.page(params[:page])
    else
      @event_import_results = @event_import_results.page(params[:page])
    end
  end
end
