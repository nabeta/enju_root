class Basket < ActiveRecord::Base
  named_scope :will_expire, lambda {|date| {:conditions => ['created_at < ?', date]}}
  belongs_to :user, :validate => true
  has_many :checked_items, :dependent => :destroy
  has_many :items, :through => :checked_items
  has_many :checkouts
  has_many :checkins

  validates_associated :user
  # 貸出完了後にかごのユーザidは破棄する
  validates_presence_of :user, :on => :create

  cattr_accessor :user_number
  
  def basket_checkout(librarian)
    return nil if self.checked_items.size == 0
    self.checked_items.each do |checked_item|
      checkout = self.user.checkouts.new(:librarian_id => librarian.id, :item_id => checked_item.item.id, :basket_id => self.id, :due_date => checked_item.due_date)
      checked_item.destroy
      checked_item.item.checkout!(self.user)
      checkout.save!
    end
  end

end
