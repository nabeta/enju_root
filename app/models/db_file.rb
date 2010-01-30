class DbFile < ActiveRecord::Base
  has_one :event_import_file
  has_one :patron_import_file
  has_one :resource_import_file
  #has_one :attachment_file
  #has_one :picture_file
  has_one :inventory_file
end
