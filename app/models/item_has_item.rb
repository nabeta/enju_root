class ItemHasItem < ActiveRecord::Base
  belongs_to :item_from_item, :foreign_key => 'from_item_id', :class_name => 'Item'
  belongs_to :item_to_item, :foreign_key => 'to_item_id', :class_name => 'Item'

  validates_uniqueness_of [:from_item_id, :to_item_id]
end
