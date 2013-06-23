class Family < ActiveRecord::Base
  attr_accessible :dates, :field_of_activity, :history, :identifier_id, :name_id, :places_associated, :type_of_family
end
