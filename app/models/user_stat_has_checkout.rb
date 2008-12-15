class UserStatHasCheckout < ActiveRecord::Base
  belongs_to :user_stat
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :user_stat_id
end
