require 'test_helper'

class CarrierTypesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :carrier_types, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:carrier_types)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:carrier_types)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:carrier_types)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:carrier_types)
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
  
  def test_guest_should_not_create_carrier_type
    old_count = CarrierType.count
    post :create, :carrier_type => { }
    assert_equal old_count, CarrierType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_carrier_type
    UserSession.create users(:user1)
    old_count = CarrierType.count
    post :create, :carrier_type => { }
    assert_equal old_count, CarrierType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_carrier_type
    UserSession.create users(:librarian1)
    old_count = CarrierType.count
    post :create, :carrier_type => { }
    assert_equal old_count, CarrierType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_carrier_type_without_name
    UserSession.create users(:admin)
    old_count = CarrierType.count
    post :create, :carrier_type => { }
    assert_equal old_count, CarrierType.count
    
    assert_response :success
  end

  def test_admin_should_create_carrier_type
    UserSession.create users(:admin)
    old_count = CarrierType.count
    post :create, :carrier_type => {:name => 'test'}
    assert_equal old_count+1, CarrierType.count
    
    assert_redirected_to carrier_type_url(assigns(:carrier_type))
  end

  def test_guest_should_show_carrier_type
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_carrier_type
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_carrier_type
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_carrier_type
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
  
  def test_guest_should_not_update_carrier_type
    put :update, :id => 1, :carrier_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_carrier_type
    UserSession.create users(:user1)
    put :update, :id => 1, :carrier_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_carrier_type
    UserSession.create users(:librarian1)
    put :update, :id => 1, :carrier_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_carrier_type_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :carrier_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_carrier_type
    UserSession.create users(:admin)
    put :update, :id => 1, :carrier_type => { }
    assert_redirected_to carrier_type_url(assigns(:carrier_type))
  end
  
  def test_guest_should_not_destroy_carrier_type
    old_count = CarrierType.count
    delete :destroy, :id => 1
    assert_equal old_count, CarrierType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_carrier_type
    UserSession.create users(:user1)
    old_count = CarrierType.count
    delete :destroy, :id => 1
    assert_equal old_count, CarrierType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_carrier_type
    UserSession.create users(:librarian1)
    old_count = CarrierType.count
    delete :destroy, :id => 1
    assert_equal old_count, CarrierType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_carrier_type
    UserSession.create users(:admin)
    old_count = CarrierType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, CarrierType.count
    
    assert_redirected_to carrier_types_url
  end
end
