class OrderList < ActiveRecord::Base
  named_scope :not_ordered, :conditions => ['ordered_at IS NULL']

  has_many :orders, :dependent => :destroy
  has_many :purchase_requests, :through => :orders, :conditions => 'deleted_at IS NULL'
  belongs_to :user, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :subscriptions, :conditions => 'deleted_at IS NULL'

  validates_presence_of :title, :user, :bookstore
  validates_associated :user, :bookstore

  acts_as_paranoid

  cattr_reader :per_page
  @@per_page = 10

  def total_price
    self.purchase_requests.sum(:price)
  end
end
