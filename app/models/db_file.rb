class DbFile < ActiveRecord::Base
  has_one :imported_event_file
  has_one :imported_patron_file
  has_one :imported_resource_file
  #has_one :attachment_file
  #has_one :picture_file
  has_one :inventory_file
end
