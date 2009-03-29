require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :subjects, :users, :manifestations, :resource_has_subjects

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:subjects)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:subjects)
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
  
  def test_guest_should_not_create_subject
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subject
    UserSession.create users(:user1)
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subject
    UserSession.create users(:librarian1)
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_subject_without_term
    UserSession.create users(:admin)
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :success
  end

  def test_admin_should_create_subject
    UserSession.create users(:admin)
    old_count = Subject.count
    post :create, :subject => {:term => 'test', :subject_type_id => 1}
    assert_equal old_count+1, Subject.count
    
    assert_redirected_to subject_url(assigns(:subject))
  end

  def test_guest_should_show_subject
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_guest_should_show_subject_with_manifestation
    get :show, :id => subjects(:subject_00001).to_param, :manifestation_id => 1
    assert_response :success
    assert assigns(:subject)
    assert assigns(:manifestation)
  end

  def test_user_should_show_subject
    UserSession.create users(:user1)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_librarian_should_show_subject
    UserSession.create users(:librarian1)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_admin_should_show_subject
    UserSession.create users(:admin)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => subjects(:subject_00001).to_param
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :success
  end
  
  def test_admin_should_get_edit_with_manifestation
    UserSession.create users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :manifestation_id => 1
    assert_response :success
  end
  
  def test_admin_should_not_get_edit_with_missing_manifestation
    UserSession.create users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :manifestation_id => 100
    assert_response :missing
  end
  
  def test_guest_should_not_update_subject
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subject
    UserSession.create users(:user1)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subject
    UserSession.create users(:librarian1)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_subject_without_term
    UserSession.create users(:admin)
    put :update, :id => subjects(:subject_00001).to_param, :subject => {:term => nil}
    assert_response :success
  end
  
  def test_admin_should_update_subject
    UserSession.create users(:admin)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_redirected_to subject_url(assigns(:subject))
  end
  
  def test_guest_should_not_destroy_subject
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subject
    UserSession.create users(:user1)
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_subject
    UserSession.create users(:librarian1)
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_subject
    UserSession.create users(:admin)
    assert_difference('Subject.count', -1) do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_redirected_to subjects_url
  end
end
