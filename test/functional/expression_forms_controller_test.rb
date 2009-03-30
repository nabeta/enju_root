require 'test_helper'

class ExpressionFormsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :expression_forms, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:expression_forms)
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:expression_forms)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:expression_forms)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:expression_forms)
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
  
  def test_guest_should_not_create_expression_form
    old_count = ExpressionForm.count
    post :create, :expression_form => { }
    assert_equal old_count, ExpressionForm.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_expression_form
    UserSession.create users(:user1)
    old_count = ExpressionForm.count
    post :create, :expression_form => { }
    assert_equal old_count, ExpressionForm.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_expression_form
    UserSession.create users(:librarian1)
    old_count = ExpressionForm.count
    post :create, :expression_form => { }
    assert_equal old_count, ExpressionForm.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_expression_form_without_name
    UserSession.create users(:admin)
    old_count = ExpressionForm.count
    post :create, :expression_form => { }
    assert_equal old_count, ExpressionForm.count
    
    assert_response :success
  end

  def test_admin_should_create_expression_form
    UserSession.create users(:admin)
    old_count = ExpressionForm.count
    post :create, :expression_form => {:name => 'test'}
    assert_equal old_count+1, ExpressionForm.count
    
    assert_redirected_to expression_form_url(assigns(:expression_form))
  end

  def test_guest_should_show_expression_form
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_expression_form
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_expression_form
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_expression_form
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
  
  def test_guest_should_not_update_expression_form
    put :update, :id => 1, :expression_form => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_expression_form
    UserSession.create users(:user1)
    put :update, :id => 1, :expression_form => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_expression_form
    UserSession.create users(:librarian1)
    put :update, :id => 1, :expression_form => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_expression_form_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :expression_form => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_expression_form
    UserSession.create users(:admin)
    put :update, :id => 1, :expression_form => { }
    assert_redirected_to expression_form_url(assigns(:expression_form))
  end
  
  def test_guest_should_not_destroy_expression_form
    old_count = ExpressionForm.count
    delete :destroy, :id => 1
    assert_equal old_count, ExpressionForm.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_expression_form
    UserSession.create users(:user1)
    old_count = ExpressionForm.count
    delete :destroy, :id => 1
    assert_equal old_count, ExpressionForm.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_expression_form
    UserSession.create users(:librarian1)
    old_count = ExpressionForm.count
    delete :destroy, :id => 1
    assert_equal old_count, ExpressionForm.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_expression_form
    UserSession.create users(:admin)
    old_count = ExpressionForm.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ExpressionForm.count
    
    assert_redirected_to expression_forms_url
  end
end
