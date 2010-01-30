class MessageTemplate < ActiveRecord::Base
  include LibrarianRequired
  has_many :message_requests

  validates_uniqueness_of :status
  validates_presence_of :status, :title, :body

  acts_as_list

  cattr_accessor :per_page
  @@per_page = 10
end
