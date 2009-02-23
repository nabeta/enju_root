class EventCategory < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :events
  validates_presence_of :name

  acts_as_list
end
