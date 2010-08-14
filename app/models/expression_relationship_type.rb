class ExpressionRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :expression_relationships
end
