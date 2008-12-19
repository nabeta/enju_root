class ManifestationReserveStat < ActiveRecord::Base
  has_many :reserve_stat_has_manifestations
  has_many :manifestations, :through => :reserve_stat_has_manifestations

  @@per_page = 10
  cattr_reader :per_page
end
