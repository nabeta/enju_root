class Bookstore < ActiveRecord::Base
  include AdministratorRequired
  has_many :items
  has_many :order_lists
  
  acts_as_list
  acts_as_soft_deletable
  validates_presence_of :name
  validates_length_of :url, :maximum => 255, :allow_nil => true

  cattr_accessor :per_page
  @@per_page = 10
end
