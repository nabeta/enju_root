class ExpressionRelationship < ActiveRecord::Base
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Expression'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Expression'
  belongs_to :expression_relationship_type
  validate :check_parent

  def check_parent
    errors.add(:parent) if parent_id == child_id
  end
end
