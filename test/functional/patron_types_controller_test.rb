require 'test_helper'

class PatronTypesControllerTest < ActionController::TestCase
  fixtures :patron_types, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:patron_types)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:patron_types)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :forbidden
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:patron_types)
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
  
  def test_guest_should_not_create_patron_type
    old_count = PatronType.count
    post :create, :patron_type => { }
    assert_equal old_count, PatronType.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_patron_type
    login_as :user1
    old_count = PatronType.count
    post :create, :patron_type => { }
    assert_equal old_count, PatronType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_patron_type
    login_as :librarian1
    old_count = PatronType.count
    post :create, :patron_type => { }
    assert_equal old_count, PatronType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_patron_type_without_name
    login_as :admin
    old_count = PatronType.count
    post :create, :patron_type => { }
    assert_equal old_count, PatronType.count
    
    assert_response :success
  end

  def test_admin_should_create_patron_type
    login_as :admin
    old_count = PatronType.count
    post :create, :patron_type => {:name => 'test'}
    assert_equal old_count+1, PatronType.count
    
    assert_redirected_to patron_type_url(assigns(:patron_type))
  end

  def test_guest_should_show_patron_type
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_show_patron_type
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_patron_type
    login_as :librarian1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_admin_should_show_patron_type
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
  
  def test_guest_should_not_update_patron_type
    put :update, :id => 1, :patron_type => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_patron_type
    login_as :user1
    put :update, :id => 1, :patron_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_patron_type
    login_as :librarian1
    put :update, :id => 1, :patron_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_patron_type_without_name
    login_as :admin
    put :update, :id => 1, :patron_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_patron_type
    login_as :admin
    put :update, :id => 1, :patron_type => { }
    assert_redirected_to patron_type_url(assigns(:patron_type))
  end
  
  def test_guest_should_not_destroy_patron_type
    old_count = PatronType.count
    delete :destroy, :id => 1
    assert_equal old_count, PatronType.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_patron_type
    login_as :user1
    old_count = PatronType.count
    delete :destroy, :id => 1
    assert_equal old_count, PatronType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_patron_type
    login_as :librarian1
    old_count = PatronType.count
    delete :destroy, :id => 1
    assert_equal old_count, PatronType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_patron_type
    login_as :admin
    old_count = PatronType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, PatronType.count
    
    assert_redirected_to patron_types_url
  end
end
