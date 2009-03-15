class EventCategory < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :events
  validates_presence_of :name

  acts_as_list

  @@per_page = 10
  cattr_accessor :per_page
end
