require 'test_helper'

class SearchHistoriesControllerTest < ActionController::TestCase
  fixtures :search_histories, :users

  def test_guest_should_not_get_index
    get :index, :user_id => users(:admin).login
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
  end

  def test_librarian_should_get_failed_search_index
    login_as :librarian1
    get :index, :mode => 'not_found'
    assert_response :success
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
  end

  def test_guest_should_not_get_new
    get :new, :user_id => 1
    assert_redirected_to new_session_url
  end
  
  def test_everyone_should_not_get_new
    login_as :admin
    get :new
    assert_response :forbidden
  end
  
  def test_guest_should_not_create_search_history
    old_count = SearchHistory.count
    post :create, :search_history => { }
    assert_equal old_count, SearchHistory.count
    
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_create_search_history
    # 履歴を直接作成することはできない
    login_as :admin
    old_count = SearchHistory.count
    post :create, :search_history => {:query => 'test', :user_id => users(:admin).login}
    assert_equal old_count, SearchHistory.count
    
    #assert_redirected_to search_history_url(assigns(:search_history))
    assert_response :forbidden
  end

  def test_guest_should_not_show_search_history
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_search_history
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_search_history
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_search_history
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_everyone_should_not_show_missing_search_history
    login_as :admin
    get :show, :id => 100
    assert_response :missing
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_everyone_should_not_get_edit
    login_as :admin
    get :edit, :id => 3
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_search_history
    put :update, :id => 1, :search_history => { }
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_update_search_history
    login_as :admin
    put :update, :id => 1, :search_history => { }
    assert_response :forbidden
  end

  def test_guest_should_not_destroy_search_history
    old_count = SearchHistory.count
    delete :destroy, :id => 1
    assert_equal old_count, SearchHistory.count
    
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_destroy_search_history
    login_as :admin
    old_count = SearchHistory.count
    delete :destroy, :id => 3
    assert_equal old_count, SearchHistory.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_missing_search_history
    login_as :admin
    old_count = SearchHistory.count
    delete :destroy, :id => 100
    assert_equal old_count, SearchHistory.count
    
    #assert_response :missing
    assert_response :forbidden
  end
end
