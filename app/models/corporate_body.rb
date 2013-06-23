class CorporateBody < ActiveRecord::Base
  attr_accessible :address, :date_associated, :field_of_activity, :history, :language_id, :other_information, :place_associated
end
