class ExpressionHasExpression < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_expression, :foreign_key => 'from_expression_id', :class_name => 'Expression'
  belongs_to :to_expression, :foreign_key => 'to_expression_id', :class_name => 'Expression'
  belongs_to :expression_relationship_type

  validates_presence_of :from_expression, :to_expression, :expression_relationship_type
  validates_uniqueness_of :from_expression_id, :scope => :to_expression_id

  acts_as_list :scope => :from_expression

  def before_save
    Expression.find(from_expression_id_was).send_later(:save_with_index)
    Expression.find(to_expression_id_was).send_later(:save_with_index!)
  end

  def after_save
    from_expression.send_later(:save_with_index)
    to_expression.send_later(:save_with_index!)
  end
end
