class ItemRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :item_relationships
end
