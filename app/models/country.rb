class Country < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :patrons
  #has_many :people
  #has_many :corporate_bodies
  #has_many :families
  
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso, :alpha_2
  # alias_attribute :iso3, :alpha_3
  # alias_attribute :numeric, :numeric_3
  
  # Validations
  validates_presence_of :name, :display_name, :alpha_2, :alpha_3, :numeric_3
  acts_as_list
  
  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end
end
