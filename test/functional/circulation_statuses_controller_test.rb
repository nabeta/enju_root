require 'test_helper'

class CirculationStatusesControllerTest < ActionController::TestCase
  fixtures :circulation_statuses, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    login_as :librarian1
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_circulation_status
    old_count = CirculationStatus.count
    post :create, :circulation_status => { }
    assert_equal old_count, CirculationStatus.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_circulation_status
    login_as :user1
    old_count = CirculationStatus.count
    post :create, :circulation_status => { }
    assert_equal old_count, CirculationStatus.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_circulation_status
    login_as :librarian1
    old_count = CirculationStatus.count
    post :create, :circulation_status => { }
    assert_equal old_count, CirculationStatus.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_circulation_status_without_name
    login_as :admin
    old_count = CirculationStatus.count
    post :create, :circulation_status => { }
    assert_equal old_count, CirculationStatus.count
    
    assert_response :success
  end

  def test_admin_should_create_circulation_status
    login_as :admin
    old_count = CirculationStatus.count
    post :create, :circulation_status => {:name => 'test'}
    assert_equal old_count+1, CirculationStatus.count
    
    assert_redirected_to circulation_status_url(assigns(:circulation_status))
  end

  def test_guest_should_show_circulation_status
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_circulation_status
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_circulation_status
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_circulation_status
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_circulation_status
    put :update, :id => 1, :circulation_status => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_circulation_status
    login_as :user1
    put :update, :id => 1, :circulation_status => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_circulation_status
    login_as :librarian1
    put :update, :id => 1, :circulation_status => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_circulation_status_without_name
    login_as :admin
    put :update, :id => 1, :circulation_status => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_circulation_status
    login_as :admin
    put :update, :id => 1, :circulation_status => { }
    assert_redirected_to circulation_status_url(assigns(:circulation_status))
  end
  
  def test_guest_should_not_destroy_circulation_status
    old_count = CirculationStatus.count
    delete :destroy, :id => 1
    assert_equal old_count, CirculationStatus.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_circulation_status
    login_as :user1
    old_count = CirculationStatus.count
    delete :destroy, :id => 1
    assert_equal old_count, CirculationStatus.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_circulation_status
    login_as :librarian1
    old_count = CirculationStatus.count
    delete :destroy, :id => 1
    assert_equal old_count, CirculationStatus.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_circulation_status
    login_as :admin
    old_count = CirculationStatus.count
    delete :destroy, :id => 1
    assert_equal old_count-1, CirculationStatus.count
    
    assert_redirected_to circulation_statuses_url
  end
end
