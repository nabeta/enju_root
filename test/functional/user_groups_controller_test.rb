require 'test_helper'

class UserGroupsControllerTest < ActionController::TestCase
  fixtures :user_groups, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:user_groups)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:user_groups)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:user_groups)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:user_groups)
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
  
  def test_guest_should_not_create_user_group
    old_count = UserGroup.count
    post :create, :user_group => { }
    assert_equal old_count, UserGroup.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_user_group
    login_as :user1
    old_count = UserGroup.count
    post :create, :user_group => { }
    assert_equal old_count, UserGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_user_group
    login_as :librarian1
    old_count = UserGroup.count
    post :create, :user_group => { }
    assert_equal old_count, UserGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_user_group_without_name
    login_as :admin
    old_count = UserGroup.count
    post :create, :user_group => { }
    assert_equal old_count, UserGroup.count
    
    assert_response :success
  end

  def test_admin_should_create_user_group
    login_as :admin
    old_count = UserGroup.count
    post :create, :user_group => {:name => 'test'}
    assert_equal old_count+1, UserGroup.count
    
    assert_redirected_to user_group_url(assigns(:user_group))
  end

  #def test_admin_should_create_user_group_with_library_id
  #  login_as :admin
  #  old_count = UserGroup.count
  #  post :create, :user_group => {:name => 'test'}, :library_id => 1
  #  assert_equal old_count+1, UserGroup.count
  #  
  #  assert assigns(:library)
  #  assert_redirected_to user_group_url(assigns(:user_group))
  #end

  def test_guest_should_show_user_group
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_user_group
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_user_group
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_user_group
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
  
  def test_guest_should_not_update_user_group
    put :update, :id => 1, :user_group => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_user_group
    login_as :user1
    put :update, :id => 1, :user_group => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_user_group
    login_as :librarian1
    put :update, :id => 1, :user_group => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_user_group_without_name
    login_as :admin
    put :update, :id => 1, :user_group => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_user_group
    login_as :admin
    put :update, :id => 1, :user_group => { }
    assert_redirected_to user_group_url(assigns(:user_group))
  end
  
  def test_guest_should_not_destroy_user_group
    old_count = UserGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, UserGroup.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_user_group
    login_as :user1
    old_count = UserGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, UserGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_user_group
    login_as :librarian1
    old_count = UserGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, UserGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_user_group
    login_as :admin
    old_count = UserGroup.count
    delete :destroy, :id => 1
    assert_equal old_count-1, UserGroup.count
    
    assert_redirected_to user_groups_url
  end
end
