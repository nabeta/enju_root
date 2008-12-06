require File.dirname(__FILE__) + '/../test_helper'

class BookmarkedResourceTest < ActiveSupport::TestCase
  fixtures :bookmarked_resources, :bookmarks, :users

  # Replace this with your real tests.
  def test_bookmarked_by_user
    assert bookmarked_resources(:bookmarked_resource_00001).bookmarked?(users(:admin))
  end

  def test_not_bookmarked_by_user
    assert_equal false, bookmarked_resources(:bookmarked_resource_00001).bookmarked?(users(:user1))
  end
end
