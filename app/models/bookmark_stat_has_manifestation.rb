class BookmarkStatHasManifestation < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :bookmark_stat
  belongs_to :manifestation

  validates_uniqueness_of :manifestation_id, :scope => :bookmark_stat_id

  @@per_page = 10
  cattr_reader :per_page
end
