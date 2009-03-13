require 'test_helper'

class BookmarkStatTest < ActiveSupport::TestCase
  fixtures :bookmark_stats

  test "calculate manifestation count" do
    assert bookmark_stats(:one).calculate_bookmarks_count
  end
end
