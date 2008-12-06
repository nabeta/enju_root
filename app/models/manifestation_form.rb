class ManifestationForm < ActiveRecord::Base
  include DisplayName
  has_many :manifestations
  #has_many :available_manifestation_forms
  #has_many :user_groups, :through => :available_manifestation_forms
  has_many :manifestation_form_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :manifestation_form_has_checkout_types

  validates_presence_of :name

  acts_as_list

end
