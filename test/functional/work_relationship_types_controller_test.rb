require 'test_helper'

class WorkRelationshipTypesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :work_relationship_types, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:work_relationship_types)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:work_relationship_types)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:work_relationship_types)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:work_relationship_types)
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
  
  def test_guest_should_not_create_work_relationship_type
    assert_no_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work_relationship_type
    UserSession.create users(:user1)
    assert_no_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_relationship_type
    UserSession.create users(:librarian1)
    assert_no_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_work_relationship_type_without_name
    UserSession.create users(:admin)
    assert_no_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_work_relationship_type
    UserSession.create users(:admin)
    assert_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => {:name => 'test', :display_name => 'test'}
    end
    
    assert_redirected_to work_relationship_type_url(assigns(:work_relationship_type))
  end

  def test_guest_should_show_work_relationship_type
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work_relationship_type
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work_relationship_type
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_work_relationship_type
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
  
  def test_guest_should_not_update_work_relationship_type
    put :update, :id => 1, :work_relationship_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_work_relationship_type
    UserSession.create users(:user1)
    put :update, :id => 1, :work_relationship_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_relationship_type
    UserSession.create users(:librarian1)
    put :update, :id => 1, :work_relationship_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_work_relationship_type_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :work_relationship_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_work_relationship_type
    UserSession.create users(:admin)
    put :update, :id => 1, :work_relationship_type => { }
    assert_redirected_to work_relationship_type_url(assigns(:work_relationship_type))
  end
  
  def test_guest_should_not_destroy_work_relationship_type
    old_count = WorkRelationshipType.count
    delete :destroy, :id => 1
    assert_equal old_count, WorkRelationshipType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_work_relationship_type
    UserSession.create users(:user1)
    assert_no_difference('WorkRelationshipType.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_work_relationship_type
    UserSession.create users(:librarian1)
    assert_no_difference('WorkRelationshipType.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_work_relationship_type
    UserSession.create users(:admin)
    assert_difference('WorkRelationshipType.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to work_relationship_types_url
  end
end
