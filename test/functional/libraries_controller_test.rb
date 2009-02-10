require File.dirname(__FILE__) + '/../test_helper'
require 'libraries_controller'

class LibrariesControllerTest < ActionController::TestCase
  fixtures :libraries, :users, :corporate_bodies

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:libraries)
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
  
  def test_guest_should_not_create_library
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :short_name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_library
    login_as :user1
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :short_name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_library
    login_as :librarian1
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :short_name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_without_name
    login_as :admin
    old_count = Library.count
    post :create, :library => { :short_name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_not_create_library_without_short_name
    login_as :admin
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_not_create_library_without_short_display_name
    login_as :admin
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :short_name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_create_library
    login_as :admin
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :short_name => 'fujisawa', :short_display_name => '藤沢' }
    assert_equal old_count+1, Library.count
    
    assert_redirected_to library_url(assigns(:library).short_name)
  end

  def test_guest_should_show_library
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_everyone_should_not_show_missing_library
    login_as :admin
    get :show, :id => 'hiyoshi'
    assert_response :missing
  end

  def test_user_should_show_library
    login_as :user1
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_librarian_should_show_library
    login_as :librarian1
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_admin_should_show_library
    login_as :admin
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 'kamata'
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 'kamata'
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => 'kamata'
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 'kamata'
    assert_response :success
  end
  
  def test_guest_should_not_update_library
    put :update, :id => 'kamata', :library => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_library
    login_as :user1
    put :update, :id => 'kamata', :library => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_library
    login_as :librarian1
    put :update, :id => 'kamata', :library => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_library_without_name
    login_as :admin
    put :update, :id => 'kamata', :library => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_not_update_library_without_short_name
    login_as :admin
    put :update, :id => 'kamata', :library => {:short_name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_library
    login_as :admin
    put :update, :id => 'kamata', :library => { }
    assert_redirected_to library_url(assigns(:library).short_name)
  end
  
  def test_guest_should_not_destroy_library
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_library
    login_as :user1
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_library
    login_as :librarian1
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_library_id_1
    login_as :admin
    old_count = Library.count
    delete :destroy, :id => 'web'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_library
    login_as :admin
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count-1, Library.count
    
    assert_redirected_to libraries_url
  end
end
