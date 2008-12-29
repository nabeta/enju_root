class ManifestationReserveStat < ActiveRecord::Base
  include AASM
  has_many :reserve_stat_has_manifestations
  has_many :manifestations, :through => :reserve_stat_has_manifestations

  aasm_initial_state :pending
  aasm_column :state

  @@per_page = 10
  cattr_reader :per_page
end
