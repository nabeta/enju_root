class EventCategory < ActiveRecord::Base
  has_many :events
  validates_presence_of :name

  acts_as_list
end
