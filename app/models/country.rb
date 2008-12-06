class Country < ActiveRecord::Base
  include DisplayName
  has_many :patrons
  
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso, :alpha_2
  # alias_attribute :iso3, :alpha_3
  # alias_attribute :numeric, :numeric_3
  
  # Validations
  validates_presence_of :name, :alpha_2, :alpha_3, :numeric_3
  acts_as_list
  
end
