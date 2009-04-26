class ManifestationForm < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :manifestations
  #has_many :available_manifestation_forms
  #has_many :user_groups, :through => :available_manifestation_forms
  has_many :manifestation_form_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :manifestation_form_has_checkout_types

  validates_presence_of :name

  acts_as_list
  acts_as_cached

  def before_save
    self.expire_cache
  end

  def before_destroy
    self.expire_cache
  end

end
