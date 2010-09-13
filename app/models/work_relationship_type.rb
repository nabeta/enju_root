class WorkRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :work_relationships
end
