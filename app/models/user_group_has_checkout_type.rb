class UserGroupHasCheckoutType < ActiveRecord::Base
  include AdministratorRequired
  named_scope :available_for_item, lambda {|item| {:conditions => {:checkout_type_id => item.checkout_type.id}}}
  named_scope :available_for_carrier_type, lambda {|carrier_type| {:include => {:checkout_type => :carrier_types}, :conditions => ['carrier_types.id = ?', carrier_type.id]}}

  belongs_to :user_group, :validate => true
  belongs_to :checkout_type, :validate => true

  validates_presence_of :user_group_id, :checkout_type_id
  validates_associated :user_group, :checkout_type
  validates_uniqueness_of :checkout_type_id, :scope => :user_group_id

  acts_as_list :scope => :user_group_id

end
