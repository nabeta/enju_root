class WorkRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @work_relationship_types = WorkRelationshipType.all
  end

  def index
    @work_relationships = WorkRelationship.page(params[:page])
  end

  def new
    @work_relationship = WorkRelationship.new(params[:work_relationship])
    @work_relationship.parent = Work.find(params[:work_id]) rescue nil
    @work_relationship.child = Work.find(params[:child_id]) rescue nil
  end
end
