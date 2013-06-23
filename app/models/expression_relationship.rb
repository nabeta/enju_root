class ExpressionRelationship < ActiveRecord::Base
  attr_accessible :child_id, :parent_id, :expression_relationship_type_id

  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Expression'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Expression'
  #belongs_to :expression_relationship_type
  validate :check_parent
  validates :parent_id, :presence => true
  validates :child_id, :uniqueness => {:scope => :parent_id}, :presence => true

  def check_parent
    errors.add(:parent) if parent_id == child_id
  end
end
