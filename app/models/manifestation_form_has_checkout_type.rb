class ManifestationFormHasCheckoutType < ActiveRecord::Base
  named_scope :available_for_manifestation_form, lambda {|manifestation_form| {:include => :manifestation_forms, :conditions => ['manifestation_forms.name = ?', manifestation_form.name]}}
  named_scope :available_for_user_group, lambda {|user_group| {:include => :user_groups, :conditions => ['user_groups.name = ?', user_group.name]}}

  belongs_to :manifestation_form, :validate => true
  belongs_to :checkout_type, :validate => true

  validates_presence_of :manifestation_form_id, :checkout_type_id
  validates_associated :manifestation_form, :checkout_type
  validates_uniqueness_of :checkout_type_id, :scope => :manifestation_form_id

  acts_as_list :scope => :manifestation_form_id
end
