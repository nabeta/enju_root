class BookmarkStatHasManifestation < ActiveRecord::Base
  belongs_to :bookmark_stat
  belongs_to :manifestation
end
