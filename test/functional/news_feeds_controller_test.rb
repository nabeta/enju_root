require 'test_helper'

class NewsFeedsControllerTest < ActionController::TestCase
  fixtures :news_feeds, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:news_feeds)
  end

  #def test_user_should_not_get_index
  #  set_session_for users(:user1)
  #  get :index
  #  assert_response :forbidden
  #end

  #def test_librarian_should_not_get_index
  #  set_session_for users(:librarian1)
  #  get :index
  #  assert_response :forbidden
  #end

  #def test_admin_should_get_index
  #  set_session_for users(:admin)
  #  get :index
  #  assert_response :success
  #  assert assigns(:news_feeds)
  #end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    set_session_for users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_new
    set_session_for users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    set_session_for users(:admin)
    get :new
    assert_response :success
    assert assigns(:news_feed)
  end
  
  def test_guest_should_not_create_news_feed
    old_count = NewsFeed.count
    post :create, :news_feed => { }
    assert_equal old_count, NewsFeed.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_news_feed
    set_session_for users(:user1)
    old_count = NewsFeed.count
    post :create, :news_feed => { }
    assert_equal old_count, NewsFeed.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_news_feed
    set_session_for users(:librarian1)
    old_count = NewsFeed.count
    post :create, :news_feed => { }
    assert_equal old_count, NewsFeed.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_news_feed_without_url
    set_session_for users(:admin)
    old_count = NewsFeed.count
    post :create, :news_feed => { }
    assert_equal old_count, NewsFeed.count
    
    assert_response :success
  end

  def test_admin_should_create_news_feed
    set_session_for users(:admin)
    old_count = NewsFeed.count
    post :create, :news_feed => {:title => 'test', :url => 'test'}
    assert_equal old_count+1, NewsFeed.count
    
    assert_redirected_to news_feed_url(assigns(:news_feed))
  end

  def test_guest_should_show_news_feed
    get :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:news_feed)
    #assert_redirected_to new_user_session_url
  end

  #def test_user_should_not_show_news_feed
  #  set_session_for users(:librarian1)
  #  get :show, :id => 1
  #  assert_response :forbidden
  #end

  #def test_librarian_should_not_show_news_feed
  #  set_session_for users(:librarian1)
  #  get :show, :id => 1
  #  assert_response :forbidden
  #end

  #def test_admin_should_show_news_feed
  #  set_session_for users(:admin)
  #  get :show, :id => 1
  #  assert_response :success
  #  assert assigns(:news_feed)
  #end

  def test_guest_should_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_edit
    set_session_for users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    set_session_for users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    set_session_for users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_news_feed
    put :update, :id => 1, :news_feed => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_news_feed
    set_session_for users(:user1)
    put :update, :id => 1, :news_feed => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_news_feed
    set_session_for users(:librarian1)
    put :update, :id => 1, :news_feed => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_news_feed_without_url
    set_session_for users(:admin)
    put :update, :id => 1, :news_feed => {:url => ""}
    assert_response :success
  end
  
  def test_admin_should_update_news_feed
    set_session_for users(:admin)
    put :update, :id => 1, :news_feed => { }
    assert_redirected_to news_feed_url(assigns(:news_feed))
  end
  
  def test_guest_should_not_destroy_news_feed
    old_count = NewsFeed.count
    delete :destroy, :id => 1
    assert_equal old_count, NewsFeed.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_news_feed
    set_session_for users(:user1)
    old_count = NewsFeed.count
    delete :destroy, :id => 1
    assert_equal old_count, NewsFeed.count
    
    assert_response :forbidden
  end
  
  def test_librarian_should_not_destroy_news_feed
    set_session_for users(:librarian1)
    old_count = NewsFeed.count
    delete :destroy, :id => 1
    assert_equal old_count, NewsFeed.count
    
    assert_response :forbidden
  end
  
  def test_admin_should_destroy_news_feed
    set_session_for users(:admin)
    old_count = NewsFeed.count
    delete :destroy, :id => 1
    assert_equal old_count-1, NewsFeed.count
    
    assert_redirected_to news_feeds_url
  end
end
