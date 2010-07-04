class ExpressionRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :expression_has_expressions
end
