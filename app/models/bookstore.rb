class Bookstore < ActiveRecord::Base
  has_many :items, :conditions => 'items.deleted_at IS NULL'
  has_many :order_lists, :conditions => 'order_lists.deleted_at IS NULL'
  
  acts_as_list
  acts_as_paranoid
  validates_presence_of :name
  validates_length_of :url, :maximum => 255, :allow_nil => true
end
