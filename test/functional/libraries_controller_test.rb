require 'test_helper'

class LibrariesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :libraries, :users, :corporate_bodies

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:libraries)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:libraries)
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
  
  def test_guest_should_not_create_library
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_library
    UserSession.create users(:user1)
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_library
    UserSession.create users(:librarian1)
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_without_name
    UserSession.create users(:admin)
    old_count = Library.count
    post :create, :library => { :name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_not_create_library_without_name
    UserSession.create users(:admin)
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_not_create_library_without_short_display_name
    UserSession.create users(:admin)
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :name => 'fujisawa' }
    assert_equal old_count, Library.count
    
    assert_response :success
  end

  def test_admin_should_create_library
    UserSession.create users(:admin)
    old_count = Library.count
    post :create, :library => { :name => 'Fujisawa Library', :name => 'fujisawa', :short_display_name => '藤沢' }
    assert_equal old_count+1, Library.count
    
    assert_redirected_to library_url(assigns(:library).name)
  end

  def test_guest_should_show_library
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_everyone_should_not_show_missing_library
    UserSession.create users(:admin)
    get :show, :id => 'hiyoshi'
    assert_response :missing
  end

  def test_user_should_show_library
    UserSession.create users(:user1)
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_librarian_should_show_library
    UserSession.create users(:librarian1)
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_admin_should_show_library
    UserSession.create users(:admin)
    get :show, :id => 'kamata'
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 'kamata'
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 'kamata'
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 'kamata'
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => 'kamata'
    assert_response :success
  end
  
  def test_guest_should_not_update_library
    put :update, :id => 'kamata', :library => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_library
    UserSession.create users(:user1)
    put :update, :id => 'kamata', :library => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_library
    UserSession.create users(:librarian1)
    put :update, :id => 'kamata', :library => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_library_without_name
    UserSession.create users(:admin)
    put :update, :id => 'kamata', :library => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_not_update_library_without_name
    UserSession.create users(:admin)
    put :update, :id => 'kamata', :library => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_library
    UserSession.create users(:admin)
    put :update, :id => 'kamata', :library => { }
    assert_redirected_to library_url(assigns(:library).name)
  end
  
  def test_guest_should_not_destroy_library
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_library
    UserSession.create users(:user1)
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_library
    UserSession.create users(:librarian1)
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_library_id_1
    UserSession.create users(:admin)
    old_count = Library.count
    delete :destroy, :id => 'web'
    assert_equal old_count, Library.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_library
    UserSession.create users(:admin)
    old_count = Library.count
    delete :destroy, :id => 'kamata'
    assert_equal old_count-1, Library.count
    
    assert_redirected_to libraries_url
  end
end
