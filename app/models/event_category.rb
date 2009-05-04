class EventCategory < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :events
  validates_presence_of :name

  acts_as_list

  @@per_page = 10
  cattr_accessor :per_page
end
