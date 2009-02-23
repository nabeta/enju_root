class Order < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :order_list, :validate => true
  belongs_to :purchase_request, :validate => true

  validates_associated :order_list, :purchase_request
  validates_presence_of :order_list, :purchase_request
  validates_uniqueness_of :purchase_request_id, :scope => :order_list_id
  
  acts_as_list :scope => :order_list

  cattr_reader :per_page
  @@per_page = 10
end
