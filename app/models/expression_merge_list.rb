class ExpressionMergeList < ActiveRecord::Base
  has_many :expression_merges, :dependent => :destroy
  has_many :expressions, :through => :expression_merges, :conditions => 'expressions.deleted_at IS NULL'
  validates_presence_of :title

  def merge_expressions(selected_expression)
    self.expressions.each do |expression|
      Realize.update_all(['expression_id = ?', selected_expression.id], ['expression_id = ?', expression.id])
      Reify.update_all(['expression_id = ?', selected_expression.id], ['expression_id = ?', expression.id])
      Embody.update_all(['expression_id = ?', selected_expression.id], ['expression_id = ?', expression.id])
      expression.destroy unless expression == selected_expression
    end
  end
end
