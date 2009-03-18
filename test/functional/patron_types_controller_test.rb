require 'test_helper'

class PatronTypesControllerTest < ActionController::TestCase
  fixtures :patron_types, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
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
    assert_response :success
    assert assigns(:patron_types)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:patron_types)
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
    assert_no_difference('PatronType.count') do
      post :create, :patron_type => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_patron_type
    login_as :user1
    assert_no_difference('PatronType.count') do
      post :create, :patron_type => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_patron_type
    login_as :librarian1
    assert_no_difference('PatronType.count') do
      post :create, :patron_type => { }
    end
    post :create, :patron_type => { }
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_patron_type_without_name
    login_as :admin
    assert_no_difference('PatronType.count') do
      post :create, :patron_type => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_patron_type
    login_as :admin
    assert_difference('PatronType.count') do
      post :create, :patron_type => {:name => 'test'}
    end
    
    assert_redirected_to patron_type_url(assigns(:patron_type))
  end

  def test_guest_should_not_show_patron_type
    get :show, :id => patron_types(:patron_type_00001)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_patron_type
    login_as :user1
    get :show, :id => patron_types(:patron_type_00001)
    assert_response :forbidden
  end

  def test_librarian_should_show_patron_type
    login_as :librarian1
    get :show, :id => patron_types(:patron_type_00001)
    assert_response :success
  end

  def test_admin_should_show_patron_type
    login_as :admin
    get :show, :id => patron_types(:patron_type_00001)
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => patron_types(:patron_type_00001)
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => patron_types(:patron_type_00001)
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => patron_types(:patron_type_00001)
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => patron_types(:patron_type_00001)
    assert_response :success
  end
  
  def test_guest_should_not_update_patron_type
    put :update, :id => patron_types(:patron_type_00001), :patron_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_patron_type
    login_as :user1
    put :update, :id => patron_types(:patron_type_00001), :patron_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_patron_type
    login_as :librarian1
    put :update, :id => patron_types(:patron_type_00001), :patron_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_patron_type_without_name
    login_as :admin
    put :update, :id => patron_types(:patron_type_00001), :patron_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_patron_type
    login_as :admin
    put :update, :id => patron_types(:patron_type_00001), :patron_type => { }
    assert_redirected_to patron_type_url(assigns(:patron_type))
  end
  
  def test_guest_should_not_destroy_patron_type
    assert_no_difference('PatronType.count') do
      delete :destroy, :id => patron_types(:patron_type_00001)
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_patron_type
    login_as :user1
    assert_no_difference('PatronType.count') do
      delete :destroy, :id => patron_types(:patron_type_00001)
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_patron_type
    login_as :librarian1
    assert_no_difference('PatronType.count') do
      delete :destroy, :id => patron_types(:patron_type_00001)
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_patron_type
    login_as :admin
    assert_difference('PatronType.count', -1) do
      delete :destroy, :id => patron_types(:patron_type_00001)
    end
    
    assert_redirected_to patron_types_url
  end
end
