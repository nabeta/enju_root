class ExpressionHasExpression < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_expression, :foreign_key => 'from_expression_id', :class_name => 'Expression'
  belongs_to :to_expression, :foreign_key => 'to_expression_id', :class_name => 'Expression'
  belongs_to :expression_relationship_type

  validates_presence_of :from_expression, :to_expression, :expression_relationship_type
  validates_uniqueness_of :from_expression_id, :scope => :to_expression_id

  acts_as_list :scope => :from_expression

  def before_update
    Expression.find(from_expression_id_was).index
    Expression.find(to_expression_id_was).index
  end

  def after_save
    from_expression.index
    to_expression.index
  end

  def after_destroy
    after_save
  end
end
