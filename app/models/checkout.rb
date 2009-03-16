class Checkout < ActiveRecord::Base
  include LibrarianOwnerRequired
  named_scope :not_returned, :conditions => ['checkin_id IS NULL']
  named_scope :overdue, lambda {|date| {:conditions => ['checkin_id IS NULL AND due_date < ?', date]}}
  named_scope :completed, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  
  belongs_to :user #, :counter_cache => true #, :validate => true
  belongs_to :item #, :counter_cache => true #, :validate => true
  belongs_to :checkin #, :validate => true
  belongs_to :librarian, :class_name => 'User' #, :validate => true
  belongs_to :basket #, :validate => true

  validates_associated :user, :item, :librarian, :checkin #, :basket
  # TODO: 貸出履歴を保存しない場合は、ユーザ名を削除する
  #validates_presence_of :user, :item, :basket
  validates_presence_of :item_id, :basket_id
  validates_uniqueness_of :item_id, :scope => [:basket_id, :user_id]
  validate_on_create :is_not_checked?

  cattr_accessor :per_page
  @@per_page = 10

  def is_not_checked?
    checkout = Checkout.not_returned.find(self.item) rescue nil
    unless checkout.nil?
      errors.add_to_base(I18n.t('activerecord.errors.messages.checkin.already_checked_out'))
    end
  end

  def checkout_renewable?
    return false if self.overdue?
    if self.item
      return false if self.over_checkout_renewal_limit?
      return false if self.reserved?
    end
    true
  end

  def reserved?
    return true if self.item.reserved?
  end

  def over_checkout_renewal_limit?
    return true if self.item.checkout_status(self.user).checkout_renewal_limit <= self.checkout_renewal_count
  end

  def overdue?
    tomorrow = Time.today.tomorrow
    if tomorrow > self.due_date
      return true
    else
      return false
    end
  end

  def is_today_due_date?
    today = Time.today
    if today == self.due_date.beginning_of_day
      return true
    else
      return false
    end
  end

  def set_renew_due_date(user)
    if self.item
      if self.checkout_renewal_count <= self.item.checkout_status(user).checkout_renewal_limit
        renew_due_date = self.due_date.advance(:days => self.item.checkout_status(user).checkout_period)
      else
        renew_due_date = self.due_date
      end
    end
  end

  def other_library_resource?(library)
    return true if library == self.item.shelf.library
    false
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    self.completed(start_date, end_date).find(:all, :conditions => {:item_id => manifestation.items.collect(&:id)}).count
  end

  def self.users_count(start_date, end_date, user)
    self.completed(start_date, end_date).find(:all, :conditions => {:user_id => user.id}).count
  end
end
