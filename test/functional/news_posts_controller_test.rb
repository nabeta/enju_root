require 'test_helper'

class NewsPostsControllerTest < ActionController::TestCase
  fixtures :news_posts, :users, :roles

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:news_posts)
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
  #  assert assigns(:news_posts)
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
  
  def test_librarian_should_get_new
    set_session_for users(:librarian1)
    get :new
    assert_response :success
    assert assigns(:news_post)
  end
  
  def test_admin_should_get_new
    set_session_for users(:admin)
    get :new
    assert_response :success
    assert assigns(:news_post)
  end
  
  def test_guest_should_not_create_news_post
    old_count = NewsPost.count
    post :create, :news_post => { }
    assert_equal old_count, NewsPost.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_news_post
    set_session_for users(:user1)
    old_count = NewsPost.count
    post :create, :news_post => { }
    assert_equal old_count, NewsPost.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_news_post
    set_session_for users(:librarian1)
    old_count = NewsPost.count
    post :create, :news_post => {:title => 'test', :body => 'test'}
    assert_equal old_count+1, NewsPost.count
    
    assert_redirected_to news_post_url(assigns(:news_post))
  end

  def test_admin_should_not_create_news_post_without_title
    set_session_for users(:admin)
    old_count = NewsPost.count
    post :create, :news_post => {:body => 'test'}
    assert_equal old_count, NewsPost.count
    
    assert_response :success
  end

  def test_admin_should_create_news_post
    set_session_for users(:admin)
    old_count = NewsPost.count
    post :create, :news_post => {:title => 'test', :body => 'test'}
    assert_equal old_count+1, NewsPost.count
    
    assert_redirected_to news_post_url(assigns(:news_post))
  end

  def test_guest_should_show_news_post
    get :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:news_post)
    #assert_redirected_to new_user_session_url
  end

  #def test_user_should_not_show_news_post
  #  set_session_for users(:librarian1)
  #  get :show, :id => 1
  #  assert_response :forbidden
  #end

  #def test_librarian_should_not_show_news_post
  #  set_session_for users(:librarian1)
  #  get :show, :id => 1
  #  assert_response :forbidden
  #end

  #def test_admin_should_show_news_post
  #  set_session_for users(:admin)
  #  get :show, :id => 1
  #  assert_response :success
  #  assert assigns(:news_post)
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
  
  def test_librarian_should_get_edit
    set_session_for users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    set_session_for users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_news_post
    put :update, :id => 1, :news_post => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_news_post
    set_session_for users(:user1)
    put :update, :id => 1, :news_post => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_update_news_post
    set_session_for users(:librarian1)
    put :update, :id => 1, :news_post => { }
    assert_redirected_to news_post_url(assigns(:news_post))
  end
  
  def test_admin_should_not_update_news_post_without_title
    set_session_for users(:admin)
    put :update, :id => 1, :news_post => {:title => ""}
    assert_response :success
  end
  
  def test_admin_should_update_news_post
    set_session_for users(:admin)
    put :update, :id => 1, :news_post => { }
    assert_redirected_to news_post_url(assigns(:news_post))
  end
  
  def test_guest_should_not_destroy_news_post
    old_count = NewsPost.count
    delete :destroy, :id => 1
    assert_equal old_count, NewsPost.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_news_post
    set_session_for users(:user1)
    old_count = NewsPost.count
    delete :destroy, :id => 1
    assert_equal old_count, NewsPost.count
    
    assert_response :forbidden
  end
  
  def test_librarian_should_destroy_news_post
    set_session_for users(:librarian1)
    old_count = NewsPost.count
    delete :destroy, :id => 1
    assert_equal old_count-1, NewsPost.count
    
    assert_redirected_to news_posts_url
  end
  
  def test_admin_should_destroy_news_post
    set_session_for users(:admin)
    old_count = NewsPost.count
    delete :destroy, :id => 1
    assert_equal old_count-1, NewsPost.count
    
    assert_redirected_to news_posts_url
  end
end
