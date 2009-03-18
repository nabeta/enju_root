require 'test_helper'

class ManifestationFormHasCheckoutTypesControllerTest < ActionController::TestCase
  fixtures :manifestation_form_has_checkout_types, :users, :manifestation_forms, :checkout_types

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:manifestation_form_has_checkout_types)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:manifestation_form_has_checkout_types)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:manifestation_form_has_checkout_types)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:manifestation_form_has_checkout_types)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_new
    login_as :librarian1
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_manifestation_form_has_checkout_type
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :manifestation_form_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_manifestation_form_has_checkout_type
    login_as :user1
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :manifestation_form_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_manifestation_form_has_checkout_type
    login_as :librarian1
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :manifestation_form_has_checkout_type => { }
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_manifestation_form_has_checkout_type_already_created
    login_as :admin
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :manifestation_form_has_checkout_type => {:manifestation_form_id =>1, :checkout_type_id => 1}
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :success
  end

  def test_admin_should_create_manifestation_form_has_checkout_type
    login_as :admin
    old_count = ManifestationFormHasCheckoutType.count
    post :create, :manifestation_form_has_checkout_type => {:manifestation_form_id =>1, :checkout_type_id => 3}
    assert_equal old_count+1, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to manifestation_form_has_checkout_type_url(assigns(:manifestation_form_has_checkout_type))
  end

  def test_guest_should_not_show_manifestation_form_has_checkout_type
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_manifestation_form_has_checkout_type
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_manifestation_form_has_checkout_type
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_manifestation_form_has_checkout_type
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
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
  
  def test_guest_should_not_update_manifestation_form_has_checkout_type
    put :update, :id => 1, :manifestation_form_has_checkout_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_manifestation_form_has_checkout_type
    login_as :user1
    put :update, :id => 1, :manifestation_form_has_checkout_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_manifestation_form_has_checkout_type
    login_as :librarian1
    put :update, :id => 1, :manifestation_form_has_checkout_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_manifestation_form_has_checkout_type
    login_as :admin
    put :update, :id => 1, :manifestation_form_has_checkout_type => { }
    assert_redirected_to manifestation_form_has_checkout_type_url(assigns(:manifestation_form_has_checkout_type))
  end
  
  def test_guest_should_not_destroy_manifestation_form_has_checkout_type
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_manifestation_form_has_checkout_type
    login_as :user1
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_manifestation_form_has_checkout_type
    login_as :librarian1
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, ManifestationFormHasCheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_manifestation_form_has_checkout_type
    login_as :admin
    old_count = ManifestationFormHasCheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ManifestationFormHasCheckoutType.count
    
    assert_redirected_to manifestation_form_has_checkout_types_url
  end
end
