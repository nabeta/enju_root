class UserCheckoutStat < ActiveRecord::Base
  include AASM
  include OnlyLibrarianCanModify
  has_many :checkout_stat_has_users
  has_many :users, :through => :checkout_stat_has_users

  validates_presence_of :start_date, :end_date

  aasm_initial_state :pending
  aasm_column :state

  @@per_page = 10
  cattr_accessor :per_page

  def validate
    if self.start_date and self.end_date
      if self.start_date >= self.end_date
        errors.add(:start_date)
        errors.add(:end_date)
      end
    end
  end

  def calculate_user_count
    User.each do |user|
      daily_count = Checkout.users_count(self.start_date, self.end_date, user)
      if daily_count > 0
        self.users << user
        UserCheckoutStat.find_by_sql(['UPDATE checkout_stat_has_users SET checkouts_count = ? WHERE user_checkout_stat_id = ? AND user_id = ?', daily_count, self.id, user.id])
      end
    end
  end
end
