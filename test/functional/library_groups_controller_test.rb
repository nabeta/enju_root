require File.dirname(__FILE__) + '/../test_helper'
require 'library_groups_controller'

class LibraryGroupsControllerTest < ActionController::TestCase
  fixtures :library_groups, :users, :libraries

  def test_guest_should_not_get_index
    get :index
    assert_response :success
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :success
  end

  def test_librarian_should_not_get_index
    login_as :librarian1
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:library_groups)
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
  
  def test_guest_should_not_create_library_group
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_library_group
    login_as :user1
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_library_group
    login_as :librarian1
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_group_without_name
    login_as :admin
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_group
    login_as :admin
    old_count = LibraryGroup.count
    post :create, :library_group => {:name => 'test'}
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
    #assert_redirected_to library_group_url(assigns(:library_group))
  end

  def test_guest_should_show_library_group
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_library_group
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_library_group
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_library_group
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
  
  def test_guest_should_not_update_library_group
    put :update, :id => 1, :library_group => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_library_group
    login_as :user1
    put :update, :id => 1, :library_group => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_library_group
    login_as :librarian1
    put :update, :id => 1, :library_group => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_library_group_without_name
    login_as :admin
    put :update, :id => 1, :library_group => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_library_group
    login_as :admin
    put :update, :id => 1, :library_group => { }
    assert_redirected_to library_group_url(assigns(:library_group))
  end
  
  def test_guest_should_not_destroy_library_group
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_library_group
    login_as :user1
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_library_group
    login_as :librarian1
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_destroy_library_group
    login_as :admin
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
    #assert_redirected_to library_groups_url
  end
end
