class Language < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify

  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso1, :iso_639_1
  # alias_attribute :iso2, :iso_639_2
  # alias_attribute :iso3, :iso_639_3
  
  # Validations
  validates_presence_of :name
  acts_as_list
  
end
