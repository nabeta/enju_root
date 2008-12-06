require File.dirname(__FILE__) + '/../test_helper'
require 'roles_controller'

class RolesControllerTest < ActionController::TestCase
  fixtures :roles, :users

  def test_guest_should_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
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
    assert assigns(:roles)
  end

  #def test_guest_should_not_get_new
  #  get :new
  #  assert_response :redirect
  #  assert_redirected_to new_session_url
  #end
  
  #def test_user_should_not_get_new
  #  login_as :user1
  #  get :new
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_not_get_new
  #  login_as :librarian1
  #  get :new
  #  assert_response :forbidden
  #end
  
  #def test_admin_should_get_new
  #  login_as :admin
  #  get :new
  #  assert_response :success
  #  assert assigns(:role)
  #end
  
  #def test_guest_should_not_create_role
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :redirect
  #  assert_redirected_to new_session_url
  #end

  #def test_user_should_not_create_role
  #  login_as :user1
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end

  #def test_librarian_should_not_create_role
  #  login_as :librarian1
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end

  #def test_admin_should_create_role_without_name
  #  login_as :admin
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :success
  #end

  #def test_admin_should_create_role
  #  login_as :admin
  #  old_count = Role.count
  #  post :create, :role => {:name => 'test'}
  #  assert_equal old_count+1, Role.count
  #  
  #  assert_redirected_to role_url(assigns(:role))
  #end

  def test_guest_should_not_show_role
    get :show, :id => 1
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_role
    login_as :librarian1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_not_show_role
    login_as :librarian1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_admin_should_show_role
    login_as :admin
    get :show, :id => 1
    assert_response :success
    assert assigns(:role)
  end

  def test_guest_should_get_edit
    get :edit, :id => 1
    assert_redirected_to new_session_url
  end
  
  def test_user_should_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_role
    put :update, :id => 1, :role => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_role
    login_as :user1
    put :update, :id => 1, :role => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_role
    login_as :librarian1
    put :update, :id => 1, :role => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_role_without_name
    login_as :admin
    put :update, :id => 1, :role => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_role
    login_as :admin
    put :update, :id => 1, :role => { }
    assert_redirected_to role_url(assigns(:role))
  end
  
  #def test_guest_should_not_destroy_role
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :redirect
  #  assert_redirected_to new_session_url
  #end

  #def test_user_should_not_destroy_role
  #  login_as :user1
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_not_destroy_role
  #  login_as :librarian1
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end
  
  #def test_admin_should_destroy_role
  #  login_as :admin
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count-1, Role.count
  #  
  #  assert_redirected_to roles_url
  #end
end
