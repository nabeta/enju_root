class PurchaseRequest < ActiveRecord::Base
  named_scope :not_ordered, :include => :order_list, :conditions => ['order_lists.ordered_at IS NULL']
  named_scope :ordered, :include => :order_list, :conditions => ['order_lists.ordered_at IS NOT NULL']

  belongs_to :user, :validate => true
  has_one :order, :dependent => :destroy
  has_one :order_list, :through => :order

  validates_associated :user
  validates_presence_of :user, :title
  validates_length_of :url, :maximum => 255, :allow_nil => true

  def validate
    errors.add(:price) unless self.price.nil? || self.price > 0.0
  end

  acts_as_soft_deletable
  acts_as_solr :fields => [:title, :author, :publisher, :isbn, {:price => :range_float}, {:pubdate => :date}, :url, :note, {:user_id => :integer}, {:accepted_at => :date}, {:denied_at => :date}]

  cattr_reader :order_list_id
  cattr_reader :per_page
  @@per_page = 10

  def pubdate
    self.date_of_publication
  end

end
