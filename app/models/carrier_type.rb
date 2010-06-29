class CarrierType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :manifestations
  #has_many :available_carrier_types
  #has_many :user_groups, :through => :available_carrier_types
  has_many :carrier_type_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :carrier_type_has_checkout_types

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete('CarrierType.all')
  end

  def mods_type
    case name
    when 'print'
      'text'
    else
      # TODO: その他のタイプ
      'software, multimedia'
    end
  end
end
