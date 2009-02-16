class MessageTemplate < ActiveRecord::Base
  has_many :message_queues

  validates_uniqueness_of :status
  validates_presence_of :status, :title, :body

  acts_as_list

  cattr_reader :per_page
  @@per_page = 10
end
