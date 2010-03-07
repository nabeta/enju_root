class Inventory < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :item
  belongs_to :inventory_file

  validates_associated :item, :inventory_file
  validates_presence_of :item_id, :inventory_file_id
  validates_uniqueness_of :item_id, :scope => :inventory_file_id

  def self.per_page
    10
  end
end
