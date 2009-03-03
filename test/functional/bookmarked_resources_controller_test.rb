require 'test_helper'

class BookmarkedResourcesControllerTest < ActionController::TestCase
  fixtures :bookmarked_resources, :bookmarks, :manifestations
  fixtures :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_get_my_index
    login_as :user1
    get :index, :user_id => 'user1'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_user_should_get_my_index_feed
    login_as :user1
    get :index, :user_id => 'user1', :format => 'rss'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_user_should_get_my_bookmarks_without_user_id
    login_as :user1
    get :index
    assert_response :redirect
    assert_redirected_to user_bookmarks_url(users(:user1).login)
  end

  def test_user_should_get_other_index_if_bookmark_is_public
    login_as :user1
    get :index, :user_id => 'user2'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_user_should_get_other_index_feed_if_bookmark_is_public
    login_as :user1
    get :index, :user_id => 'user2', :format => 'rss'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_user_should_not_get_index_if_bookmark_is_private
    login_as :user2
    get :index, :user_id => 'user1'
    assert_response :forbidden
  end

  def test_librarian_should_get_index_if_bookmark_is_private
    login_as :librarian1
    get :index, :user_id => 'user1'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_librarian_should_get_index_feed_if_bookmark_is_private
    login_as :librarian1
    get :index, :user_id => 'user1', :format => 'rss'
    assert_response :success
    assert assigns(:bookmarked_resources)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end

  def test_guest_should_not_create_bookmarked_resource
    assert_no_difference('BookmarkedResource.count') do
      post :create, :bookmarked_resource => {:url => 'http://example.com/' }
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_bookmarked_resource
    login_as :user1
    assert_no_difference('BookmarkedResource.count') do
      post :create, :bookmarked_resource => {:url => 'http://example.com/', :manifestation_id => 6}
    end

    #assert_redirected_to bookmarked_resource_url(assigns(:bookmarked_resource))
    assert_response :forbidden
  end

  def test_librarian_should_not_create_bookmarked_resource_without_url
    login_as :librarian1
    assert_no_difference('BookmarkedResource.count') do
      post :create, :bookmarked_resource => { }
    end

    assert_response :success
  end

  def test_librarian_should_not_create_bookmarked_resource_without_manifestation_id
    login_as :librarian1
    assert_no_difference('BookmarkedResource.count') do
      post :create, :bookmarked_resource => {:url => 'http://example.com/' }
    end

    assert_response :success
  end

  def test_librarian_should_not_create_bookmarked_resource
    login_as :librarian1
    assert_difference('BookmarkedResource.count') do
      post :create, :bookmarked_resource => {:url => 'http://example.com/', :manifestation_id => 6}
    end

    assert_response :redirect
    assert_redirected_to bookmarked_resource_url(assigns(:bookmarked_resource))
  end

  def test_guest_should_show_bookmarked_resource
    get :show, :id => bookmarked_resources(:bookmarked_resource_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => bookmarked_resources(:bookmarked_resource_00001).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_get_edit
    login_as :user1
    get :edit, :id => bookmarked_resources(:bookmarked_resource_00001).id
    assert_response :forbidden
  end

  def test_guest_should_not_update_bookmarked_resource
    put :update, :id => bookmarked_resources(:bookmarked_resource_00001).id, :bookmarked_resource => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_update_bookmarked_resource
    login_as :user1
    put :update, :id => bookmarked_resources(:bookmarked_resource_00001).id, :bookmarked_resource => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_bookmarked_resource_without_url
    login_as :librarian1
    put :update, :id => bookmarked_resources(:bookmarked_resource_00001).id, :bookmarked_resource => {:url => ""}
    assert_response :success
  end

  def test_librarian_should_not_update_bookmarked_resource_without_manifestation_id
    login_as :librarian1
    put :update, :id => bookmarked_resources(:bookmarked_resource_00001).id, :bookmarked_resource => {:url => 'http://example.com'}
    assert_response :success
  end

  def test_librarian_should_not_update_bookmarked_resource_without_manifestation_id
    login_as :librarian1
    put :update, :id => bookmarked_resources(:bookmarked_resource_00001).id, :bookmarked_resource => {:url => 'http://example.com', :manifestation_id => 1}
    assert_redirected_to bookmarked_resource_url(assigns(:bookmarked_resource))
  end

  def test_guest_should_not_destroy_bookmarked_resource
    assert_no_difference('BookmarkedResource.count') do
      delete :destroy, :id => bookmarked_resources(:bookmarked_resource_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_bookmarked_resource
    login_as :user1
    assert_no_difference('BookmarkedResource.count') do
      delete :destroy, :id => bookmarked_resources(:bookmarked_resource_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_destroy_bookmarked_resource
    login_as :admin
    assert_difference('BookmarkedResource.count', -1) do
      delete :destroy, :id => bookmarked_resources(:bookmarked_resource_00001).id
    end

    assert_redirected_to bookmarked_resources_url
  end
end
