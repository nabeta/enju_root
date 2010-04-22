class UseRestriction < ActiveRecord::Base
  default_scope :order => 'position'
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions

  validates_presence_of :name, :display_name

  acts_as_list

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end
end
