class CheckoutStat < ActiveRecord::Base
  include AASM
  has_many :checkout_stat_has_manifestations
  has_many :manifestations, :through => :checkout_stat_has_manifestations

  aasm_initial_state :pending
  aasm_column :state

  @@per_page = 10
  cattr_reader :per_page

  def culculate_manifestations_count
    Manifestation.find(:all, :select => :id).each do |manifestation|
      daily_count = Checkout.manifestations_count(self.from_date, self.to_date, manifestation)
      #manifestation.update_attributes({:daily_checkouts_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        CheckoutStat.find_by_sql(['UPDATE checkout_stat_has_manifestations SET checkouts_count = ? WHERE checkout_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id])
      end
    end
  end

end
