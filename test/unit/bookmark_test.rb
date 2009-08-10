require File.dirname(__FILE__) + '/../test_helper'

class BookmarkTest < ActiveSupport::TestCase
  fixtures :bookmarks, :bookmarked_resources,
    :users, :patrons, :patron_types, :languages, :countries,
    :checked_items, :items, :manifestations, :exemplifies,
    :expressions, :works, :carrier_types, :expression_forms,
    :shelves, :circulation_statuses, :libraries, :library_groups,
    :users, :user_groups

  def test_bookmark_sheved
    assert bookmarks(:bookmark_00001).shelved?
  end

  def test_bookmark_create_bookmark_item
    old_count = Item.count
    bookmark = users(:user1).bookmarks.create(:bookmarked_resource_id => 5, :title => 'test')
    bookmark.create_bookmark_item
    assert_not_nil bookmarks(:bookmark_00001).bookmarked_resource.manifestation.items
    assert_equal old_count + 1, Item.count
  end

  def test_should_rewrite_my_url
    assert_equal LibraryGroup.url.rewrite_my_url, "http://localhost:3001/"
  end

  def test_should_rewrite_bookmark_url
    assert_equal "http://localhost:3001".rewrite_bookmark_url, LibraryGroup.url
  end
end
