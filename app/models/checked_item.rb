class CheckedItem < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :item #, :validate => true
  belongs_to :basket #, :validate => true

  validates_associated :item, :basket
  validates_presence_of :item, :basket
  validates_uniqueness_of :item_id, :scope => :basket_id
  
  before_create :set_due_date

  attr_accessor :item_identifier

  def item_checkout_type
    self.basket.user.user_group.user_group_has_checkout_types.available_for_item(self.item).first
  end

  def check_item_status
    messages = []
    if self.item_checkout_type.nil?
      messages << ('This user group can\'t checkout this item.')
    end

    if self.item.use_restrictions.detect{|r| r.name == 'Not For Loan'}
      messages << ('This item is not for checkout.')
    end

    if self.item.rent?
      messages << ('This item may be already checked out.')
    end
    
    if self.item.reserved?
      reserving_user = self.item.manifestation.reserving_users.find(:first, :conditions => {:id => user.id}, :order => :created_at) rescue nil
      unless reserving_user
        #errors.add_to_base(('Reserved item included!'))
        messages << ('Reserved item included!')
      end
    end
    
    checkout_count = self.basket.user.checked_item_count
    CheckoutType.find(:all).each do |checkout_type|
      manifestation_form = self.item.manifestation.manifestation_form
      if checkout_count[:"#{checkout_type.name}"] > self.item_checkout_type.checkout_limit
        #errors.add_to_base(('Excessed checkout limit.'))
        messages << ('Excessed checkout limit.')
      end
    end
    
    return messages unless messages.empty?
  end
  
  def set_due_date
    if self.item_checkout_type.nil?
      return nil
    end

    if self.item_checkout_type.fixed_due_date.blank?
      self.due_date = item_checkout_type.checkout_period.days.since Time.today
    else
      self.due_date = item_checkout_type.fixed_due_date
    end
    # 返却期限日が閉館日の場合
    while item.shelf.library.closed?(self.due_date)
      if item_checkout_type.set_due_date_before_closing_day
        self.due_date = self.due_date.yesterday
      else
        self.due_date = self.due_date.tomorrow
      end
    end
    self.due_date.end_of_day
  end
end
