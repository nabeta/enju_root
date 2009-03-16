class BookmarkStat < ActiveRecord::Base
  include AASM
  include OnlyLibrarianCanModify
  has_many :bookmark_stat_has_manifestations
  has_many :manifestations, :through => :bookmark_stat_has_manifestations

  validates_presence_of :start_date, :end_date

  aasm_initial_state :pending
  aasm_column :state

  @@per_page = 10
  cattr_accessor :per_page

  def validate
    if self.start_date and self.end_date
      if self.start_date >= self.end_date
        errors.add(:start_date)
        errors.add(:end_date)
      end
    end
  end

  def calculate_bookmarks_count
    Manifestation.find_each do |manifestation|
      daily_count = Bookmark.manifestations_count(self.start_date, self.end_date, manifestation)
      #manifestation.update_attributes({:daily_bookmarks_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        BookmarkStat.find_by_sql(['UPDATE bookmark_stat_has_manifestations SET bookmarks_count = ? WHERE bookmark_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id])
      end
    end
  end
end
