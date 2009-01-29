class UseRestriction < ActiveRecord::Base
  include DisplayName
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions

  validates_presence_of :name

  acts_as_list

end
