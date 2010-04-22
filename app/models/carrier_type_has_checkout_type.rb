class CarrierTypeHasCheckoutType < ActiveRecord::Base
  named_scope :available_for_carrier_type, lambda {|carrier_type| {:include => :carrier_type, :conditions => ['carrier_types.name = ?', carrier_type.name]}}
  named_scope :available_for_user_group, lambda {|user_group| {:include => {:checkout_type => :user_groups}, :conditions => ['user_groups.name = ?', user_group.name]}}

  belongs_to :carrier_type, :validate => true
  belongs_to :checkout_type, :validate => true

  validates_presence_of :carrier_type_id, :checkout_type_id
  validates_associated :carrier_type, :checkout_type
  validates_uniqueness_of :checkout_type_id, :scope => :carrier_type_id

  acts_as_list :scope => :carrier_type_id
end
