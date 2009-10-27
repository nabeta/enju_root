class ItemHasItem < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_item, :foreign_key => 'from_item_id', :class_name => 'Item'
  belongs_to :to_item, :foreign_key => 'to_item_id', :class_name => 'Item'
  belongs_to :item_relationship_type

  validates_presence_of :from_item, :to_item, :item_relationship_type
  validates_uniqueness_of :from_item_id, :scope => :to_item_id

  acts_as_list :scope => :from_item

  def before_update
    Item.find(from_item_id_was).index
    Item.find(to_item_id_was).index
  end

  def after_save
    from_item.index
    to_item.index
  end

  def after_destroy
    after_save
  end
end
