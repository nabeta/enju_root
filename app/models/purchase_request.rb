class PurchaseRequest < ActiveRecord::Base
  named_scope :not_ordered, :include => :order_list, :conditions => ['order_lists.ordered_at IS NULL']
  named_scope :ordered, :include => :order_list, :conditions => ['order_lists.ordered_at IS NOT NULL']

  belongs_to :user, :validate => true
  has_one :order, :dependent => :destroy
  has_one :order_list, :through => :order

  validates_associated :user
  validates_presence_of :user, :title
  validates_length_of :url, :maximum => 255, :allow_blank => true

  def validate
    errors.add(:price) unless self.price.nil? || self.price > 0.0
  end

  def after_save
    index!
  end

  def after_destroy
    after_save
  end

  searchable do
    text :title, :author, :publisher, :url
    string :isbn
    string :url
    float :price
    integer :user_id
    integer :order_list_id do
      order_list.id if order_list
    end
    time :pubdate
    time :accepted_at
    time :denied_at
    boolean :ordered do
      order_list.try(:ordered_at).present? ? true : false
    end
  end
  #acts_as_soft_deletable

  def self.per_page
    10
  end

  def pubdate
    self.date_of_publication
  end

end
