class ItemHasItem < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_item, :foreign_key => 'from_item_id', :class_name => 'Item'
  belongs_to :to_item, :foreign_key => 'to_item_id', :class_name => 'Item'
  belongs_to :item_relationship_type

  validates_presence_of :from_item, :to_item, :item_relationship_type
  validates_uniqueness_of :from_item_id, :scope => :to_item_id

  acts_as_list :scope => :from_item
end
