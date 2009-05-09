class CheckoutType < ActiveRecord::Base
  include AdministratorRequired

  default_scope :order => "checkout_types.position"
  named_scope :available_for_manifestation_form, lambda {|manifestation_form| {:include => :manifestation_forms, :conditions => ['manifestation_forms.name = ?', manifestation_form.name], :order => 'manifestation_forms.position'}}
  named_scope :available_for_user_group, lambda {|user_group| {:include => :user_groups, :conditions => ['user_groups.name = ?', user_group.name], :order => 'user_group.position'}}

  has_many :manifestation_form_has_checkout_types, :dependent => :destroy
  has_many :manifestation_forms, :through => :manifestation_form_has_checkout_types
  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :user_groups, :through => :user_group_has_checkout_types
  #has_many :item_has_checkout_types, :dependent => :destroy
  #has_many :items, :through => :item_has_checkout_types
  has_many :items

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name

  cattr_accessor :per_page
  @@per_page = 10

  acts_as_list

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end

end
