class CheckoutStatHasManifestation < ActiveRecord::Base
  belongs_to :checkout_stat
  belongs_to :manifestation

  validates_uniqueness_of :manifestation_id, :scope => :checkout_stat_id

  @@per_page = 10
  cattr_reader :per_page
end
