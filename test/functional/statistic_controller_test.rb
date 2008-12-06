require File.dirname(__FILE__) + '/../test_helper'

class StatisticControllerTest < ActionController::TestCase
  fixtures :users, :checkouts

  # Replace this with your real tests.
  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_guest_should_get_user
    get :user
    assert_response :success
  end

  def test_guest_should_get_user_checked_out
    get :user, :report => 'checked_out', :stat_from => '2000-01-01'
    assert_response :success
  end

  def test_user_should_get_user
    login_as :user1
    get :user
    assert_response :success
  end

  def test_librarian_should_get_user
    login_as :librarian1
    get :user
    assert_response :success
  end

  def test_guest_should_get_bookmark
    get :bookmark
    assert_response :success
  end

  def test_guest_should_get_bookmark_with_date
    get :bookmark
    assert_response :success
  end

  def test_guest_should_get_bookmark_all_period
    get :bookmark, :period => 'all'
    assert_response :success
  end

  def test_guest_should_get_bookmark_most_bookmarked
    get :bookmark, :report => 'most_bookmarked'
    assert_response :success
  end

  def test_guest_should_get_bookmark_most_bookmarked_with_date
    get :bookmark, :report => 'most_bookmarked', :stat_from => '2000-01-02', :stat_to => '2008-12-31'
    assert_response :success
  end

  def test_user_should_get_bookmark
    login_as :user1
    get :bookmark
    assert_response :success
  end

  def test_librarian_should_get_bookmark
    login_as :librarian1
    get :bookmark
    assert_response :success
  end

  def test_guest_should_get_manifestation
    get :manifestation
    assert_response :success
  end

  def test_guest_should_get_manifestation_most_checked_out
    get :manifestation, :report => 'most_checked_out'
    assert_response :success
  end

  def test_user_should_get_manifestation
    login_as :user1
    get :manifestation
    assert_response :success
  end

  def test_librarian_should_get_manifestation
    login_as :librarian1
    get :manifestation
    assert_response :success
  end

end
