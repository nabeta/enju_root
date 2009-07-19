require 'test_helper'

class ManifestationFormHasCheckoutTypesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :carrier_type_has_checkout_types, :users, :carrier_types, :checkout_types

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:carrier_type_has_checkout_types)
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:carrier_type_has_checkout_types)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:carrier_type_has_checkout_types)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:carrier_type_has_checkout_types)
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
  
  def test_librarian_should_not_get_new
    UserSession.create users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    UserSession.create users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_carrier_type_has_checkout_type
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :carrier_type_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_carrier_type_has_checkout_type
    UserSession.create users(:user1)
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :carrier_type_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_carrier_type_has_checkout_type
    UserSession.create users(:librarian1)
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :carrier_type_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_carrier_type_has_checkout_type_already_created
    UserSession.create users(:admin)
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :carrier_type_has_checkout_type => {:carrier_type_id =>1, :checkout_type_id => 1}
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :success
  end

  def test_admin_should_create_carrier_type_has_checkout_type
    UserSession.create users(:admin)
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :carrier_type_has_checkout_type => {:carrier_type_id =>1, :checkout_type_id => 3}
    assert_equal old_count+1, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to carrier_type_has_checkout_type_url(assigns(:carrier_type_has_checkout_type))
  end

  def test_guest_should_not_show_carrier_type_has_checkout_type
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_carrier_type_has_checkout_type
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_carrier_type_has_checkout_type
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_carrier_type_has_checkout_type
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
  
  def test_guest_should_not_update_carrier_type_has_checkout_type
    put :update, :id => 1, :carrier_type_has_checkout_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_carrier_type_has_checkout_type
    UserSession.create users(:user1)
    put :update, :id => 1, :carrier_type_has_checkout_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_carrier_type_has_checkout_type
    UserSession.create users(:librarian1)
    put :update, :id => 1, :carrier_type_has_checkout_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_carrier_type_has_checkout_type
    UserSession.create users(:admin)
    put :update, :id => 1, :carrier_type_has_checkout_type => { }
    assert_redirected_to carrier_type_has_checkout_type_url(assigns(:carrier_type_has_checkout_type))
  end
  
  def test_guest_should_not_destroy_carrier_type_has_checkout_type
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_carrier_type_has_checkout_type
    UserSession.create users(:user1)
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_carrier_type_has_checkout_type
    UserSession.create users(:librarian1)
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_carrier_type_has_checkout_type
    UserSession.create users(:admin)
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to carrier_type_has_checkout_types_url
  end
end
