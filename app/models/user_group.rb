class UserGroup < ActiveRecord::Base
  include DisplayName
  has_many :users, :conditions => 'users.deleted_at IS NULL'
  #has_many :available_manifestation_forms
  #has_many :manifestation_forms, :through => :available_manifestation_forms, :order => :position
  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :user_group_has_checkout_types, :order => :position

  validates_presence_of :name

  acts_as_list

end
