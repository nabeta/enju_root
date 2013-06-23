class WorkRelationship < ActiveRecord::Base
  attr_accessible :child_id, :parent_id, :work_relationship_type_id

  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Work'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Work'
  belongs_to :work_relationship_type
  validate :check_parent
  validates :parent_id, :presence => true
  validates :child_id, :uniqueness => {:scope => :parent_id}, :presence => true

  after_save :create_index, :generate_graph

  def check_parent
    errors.add(:parent) if parent_id == child_id
  end

  def create_index
    parent.index
    child.index
    Sunspot.commit
  end

  def generate_graph
    parent.generate_graph
    child.generate_graph
  end
end
