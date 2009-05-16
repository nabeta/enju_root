class ExpressionHasExpression < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_expression, :foreign_key => 'from_expression_id', :class_name => 'Expression'
  belongs_to :to_expression, :foreign_key => 'to_expression_id', :class_name => 'Expression'

  validates_uniqueness_of :from_expression_id, :scope => :to_expression_id

  acts_as_list :scope => :from_expression
end
