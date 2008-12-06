class UserGroupHasCheckoutType < ActiveRecord::Base
  named_scope :available_for_manifestation_form, lambda {|manifestation_form| {:include => {:checkout_type => :manifestation_forms}, :conditions => ['manifestation_forms.id = ?', manifestation_form.id]}}
  named_scope :available_for_item, lambda {|item| {:conditions => {:checkout_type_id => item.checkout_type.id}}}
  named_scope :available_for_manifestation, lambda {|manifestation| {:conditions => {:checkout_type_id => manifestation.items.collect(&:checkout_type_id)}}}

  belongs_to :user_group, :validate => true
  belongs_to :checkout_type, :validate => true

  validates_presence_of :user_group_id, :checkout_type_id
  validates_associated :user_group, :checkout_type
  validates_uniqueness_of :checkout_type_id, :scope => :user_group_id

  acts_as_list :scope => :user_group_id

end
