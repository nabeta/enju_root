require 'test_helper'

class CheckoutTypesControllerTest < ActionController::TestCase
  fixtures :checkout_types, :users, :user_groups

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:checkout_types)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:checkout_types)
  end

  def test_librarian_should_not_get_index
    login_as :librarian1
    get :index
    assert_response :forbidden
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:checkout_types)
  end

  def test_admin_should_get_index_with_user_group
    login_as :admin
    get :index, :user_group_id => 1
    assert_response :success
    assert assigns(:checkout_types)
    assert assigns(:user_group)
  end

  def test_admin_should_not_get_index_with_missing_user_group
    login_as :admin
    get :index, :user_group_id => 100
    assert_response :missing
    assert_nil assigns(:checkout_types)
    assert_nil assigns(:user_group)
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
  
  def test_guest_should_not_create_checkout_type
    old_count = CheckoutType.count
    post :create, :checkout_type => { }
    assert_equal old_count, CheckoutType.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_checkout_type
    login_as :user1
    old_count = CheckoutType.count
    post :create, :checkout_type => { }
    assert_equal old_count, CheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_checkout_type
    login_as :librarian1
    old_count = CheckoutType.count
    post :create, :checkout_type => { }
    assert_equal old_count, CheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_checkout_type_without_name
    login_as :admin
    old_count = CheckoutType.count
    post :create, :checkout_type => { }
    assert_equal old_count, CheckoutType.count
    
    assert_response :success
  end

  def test_admin_should_create_checkout_type
    login_as :admin
    old_count = CheckoutType.count
    post :create, :checkout_type => {:name => 'test'}
    assert_equal old_count+1, CheckoutType.count
    
    assert_redirected_to checkout_type_url(assigns(:checkout_type))
  end

  def test_guest_should_not_show_checkout_type
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_checkout_type
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_not_show_checkout_type
    login_as :librarian1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_admin_should_show_checkout_type
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
  
  def test_guest_should_not_update_checkout_type
    put :update, :id => 1, :checkout_type => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_checkout_type
    login_as :user1
    put :update, :id => 1, :checkout_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_checkout_type
    login_as :librarian1
    put :update, :id => 1, :checkout_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_checkout_type_without_name
    login_as :admin
    put :update, :id => 1, :checkout_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_checkout_type
    login_as :admin
    put :update, :id => 1, :checkout_type => { }
    assert_redirected_to checkout_type_url(assigns(:checkout_type))
  end
  
  def test_guest_should_not_destroy_checkout_type
    old_count = CheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, CheckoutType.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_checkout_type
    login_as :user1
    old_count = CheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, CheckoutType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_checkout_type
    login_as :librarian1
    old_count = CheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count, CheckoutType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_checkout_type
    login_as :admin
    old_count = CheckoutType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, CheckoutType.count
    
    assert_redirected_to checkout_types_url
  end
end
