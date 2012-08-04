class ExpressionRelationshipsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :prepare_options, :except => [:index, :destroy]

  def prepare_options
    @expression_relationship_types = ExpressionRelationshipType.all
  end

  def index
    @expression_relationships = ExpressionRelationship.page(params[:page])
  end

  def new
    @expression_relationship = ExpressionRelationship.new(params[:expression_relationship])
    @expression_relationship.parent = Expression.find(params[:expression_id]) rescue nil
    @expression_relationship.child = Expression.find(params[:child_id]) rescue nil
  end
end
