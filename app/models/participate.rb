class Participate < ActiveRecord::Base
  include LibrarianRequired

  belongs_to :patron
  belongs_to :event

  acts_as_list :scope => :event_id

  cattr_accessor :per_page
  @@per_page = 10
end
