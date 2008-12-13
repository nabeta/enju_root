class CheckoutStatHasManifestation < ActiveRecord::Base
  belongs_to :checkout_stat
  belongs_to :manifestation
end
