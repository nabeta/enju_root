class UserGroup < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :users
  #has_many :available_manifestation_forms
  #has_many :manifestation_forms, :through => :available_manifestation_forms, :order => :position
  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :user_group_has_checkout_types, :order => :position

  validates_presence_of :name, :display_name

  acts_as_list

  cattr_accessor :per_page
  @@per_page = 10

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end

end
