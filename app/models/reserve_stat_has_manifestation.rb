class ReserveStatHasManifestation < ActiveRecord::Base
  belongs_to :reserve_stat
  belongs_to :manifestation
end
