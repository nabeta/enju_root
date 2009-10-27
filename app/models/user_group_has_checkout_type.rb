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

  def after_create
    create_lending_policy
  end

  def after_update
    update_lending_policy
  end

  def create_lending_policy
    self.checkout_type.items.each do |item|
      item.lending_policies.create(:user_group_id => self.user_group_id, :loan_period => self.checkout_period, :renewal => self.checkout_renewal_limit)
    end
  end

  def update_lending_policy
    self.checkout_type.items.each do |item|
      item.lending_policies.each do |lending_policy|
        lending_policy.update_attributes({:loan_period => self.checkout_period, :renewal => self.checkout_renewal_limit}) if lending_policy.user_group == self.user_group
      end
    end
  end

end
