class ReserveStatHasUser < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :user_reserve_stat
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :user_reserve_stat_id

  @@per_page = 10
  cattr_accessor :per_page
end
