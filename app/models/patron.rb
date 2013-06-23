class Patron < ActiveRecord::Base
  attr_accessible :full_name, :patron_type_id
end
