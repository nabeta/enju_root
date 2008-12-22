class UserReserveStat < ActiveRecord::Base
  include AASM
  has_many :reserve_stat_has_users
  has_many :users, :through => :reserve_stat_has_users

  aasm_initial_state :pending
  aasm_column :state

  @@per_page = 10
  cattr_reader :per_page
end
