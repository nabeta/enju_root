class ItemRelationshipType < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :item_has_items
  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  acts_as_list
end
