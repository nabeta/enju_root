require 'test_helper'

class MediumOfPerformancesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :medium_of_performances, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:medium_of_performances)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:medium_of_performances)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:medium_of_performances)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:medium_of_performances)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    UserSession.create users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    UserSession.create users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    UserSession.create users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_medium_of_performance
    old_count = MediumOfPerformance.count
    post :create, :medium_of_performance => { }
    assert_equal old_count, MediumOfPerformance.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_medium_of_performance
    UserSession.create users(:user1)
    old_count = MediumOfPerformance.count
    post :create, :medium_of_performance => { }
    assert_equal old_count, MediumOfPerformance.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_medium_of_performance
    UserSession.create users(:librarian1)
    old_count = MediumOfPerformance.count
    post :create, :medium_of_performance => { }
    assert_equal old_count, MediumOfPerformance.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_medium_of_performance_without_name
    UserSession.create users(:admin)
    old_count = MediumOfPerformance.count
    post :create, :medium_of_performance => { }
    assert_equal old_count, MediumOfPerformance.count
    
    assert_response :success
  end

  def test_admin_should_create_medium_of_performance
    UserSession.create users(:admin)
    old_count = MediumOfPerformance.count
    post :create, :medium_of_performance => {:name => 'test'}
    assert_equal old_count+1, MediumOfPerformance.count
    
    assert_redirected_to medium_of_performance_url(assigns(:medium_of_performance))
  end

  def test_guest_should_show_medium_of_performance
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_medium_of_performance
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_medium_of_performance
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_medium_of_performance
    UserSession.create users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_medium_of_performance
    put :update, :id => 1, :medium_of_performance => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_medium_of_performance
    UserSession.create users(:user1)
    put :update, :id => 1, :medium_of_performance => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_medium_of_performance
    UserSession.create users(:librarian1)
    put :update, :id => 1, :medium_of_performance => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_medium_of_performance_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :medium_of_performance => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_medium_of_performance
    UserSession.create users(:admin)
    put :update, :id => 1, :medium_of_performance => { }
    assert_redirected_to medium_of_performance_url(assigns(:medium_of_performance))
  end
  
  def test_guest_should_not_destroy_medium_of_performance
    old_count = MediumOfPerformance.count
    delete :destroy, :id => 1
    assert_equal old_count, MediumOfPerformance.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_medium_of_performance
    UserSession.create users(:user1)
    old_count = MediumOfPerformance.count
    delete :destroy, :id => 1
    assert_equal old_count, MediumOfPerformance.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_medium_of_performance
    UserSession.create users(:librarian1)
    old_count = MediumOfPerformance.count
    delete :destroy, :id => 1
    assert_equal old_count, MediumOfPerformance.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_medium_of_performance
    UserSession.create users(:admin)
    old_count = MediumOfPerformance.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MediumOfPerformance.count
    
    assert_redirected_to medium_of_performances_url
  end
end
