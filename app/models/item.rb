class Item < ActiveRecord::Base
  attr_accessible :item_identifier

  searchable do
    string :item_identifier
  end

  validates :item_identifier, :presence => true
end
