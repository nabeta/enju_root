class ExpressionHasExpression < ActiveRecord::Base
  belongs_to :expression_from_expression, :foreign_key => 'from_expression_id', :class_name => 'Expression'
  belongs_to :expression_to_expression, :foreign_key => 'to_expression_id', :class_name => 'Expression'

  validates_uniqueness_of :from_expression_id, :scope => :to_expression_id
end
