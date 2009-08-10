class CarrierType < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :manifestations
  #has_many :available_carrier_types
  #has_many :user_groups, :through => :available_carrier_types
  has_many :carrier_type_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :carrier_type_has_checkout_types

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name

  acts_as_list

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete('CarrierType.all')
  end

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end

end
