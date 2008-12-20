class UserReserveStat < ActiveRecord::Base
  has_many :reserve_stat_has_users
  has_many :users, :through => :reserve_stat_has_users
end
