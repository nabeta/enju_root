class CirculationStatus < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify
  named_scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items
  validates_presence_of :name

  acts_as_list

end
