require 'test_helper'

class SubjectHeadingTypesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :subject_heading_types, :users, :subjects, :subject_types,
    :subject_heading_type_has_subjects, :manifestations, :carrier_types

  def test_guest_should_not_get_index
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
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
  
  def test_guest_should_not_create_subject_heading_type
    old_count = SubjectHeadingType.count
    post :create, :subject_heading_type => { }
    assert_equal old_count, SubjectHeadingType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subject_heading_type
    UserSession.create users(:user1)
    old_count = SubjectHeadingType.count
    post :create, :subject_heading_type => { }
    assert_equal old_count, SubjectHeadingType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subject_heading_type
    UserSession.create users(:librarian1)
    old_count = SubjectHeadingType.count
    post :create, :subject_heading_type => { }
    assert_equal old_count, SubjectHeadingType.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_subject_heading_type_without_name
    UserSession.create users(:admin)
    old_count = SubjectHeadingType.count
    post :create, :subject_heading_type => { }
    assert_equal old_count, SubjectHeadingType.count
    
    assert_response :success
  end

  def test_admin_should_create_subject_heading_type
    UserSession.create users(:admin)
    old_count = SubjectHeadingType.count
    post :create, :subject_heading_type => {:name => 'test'}
    assert_equal old_count+1, SubjectHeadingType.count
    
    assert_redirected_to subject_heading_type_url(assigns(:subject_heading_type))
  end

  def test_guest_should_show_subject_heading_type
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_user_should_show_subject_heading_type
    UserSession.create users(:user1)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_librarian_should_show_subject_heading_type
    UserSession.create users(:librarian1)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_admin_should_show_subject_heading_type
    UserSession.create users(:admin)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end
  
  def test_guest_should_not_update_subject_heading_type
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subject_heading_type
    UserSession.create users(:user1)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subject_heading_type
    UserSession.create users(:librarian1)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_subject_heading_type_without_name
    UserSession.create users(:admin)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_subject_heading_type
    UserSession.create users(:admin)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_redirected_to subject_heading_type_url(assigns(:subject_heading_type))
  end
  
  def test_guest_should_not_destroy_subject_heading_type
    old_count = SubjectHeadingType.count
    delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_equal old_count, SubjectHeadingType.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subject_heading_type
    UserSession.create users(:user1)
    old_count = SubjectHeadingType.count
    delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_equal old_count, SubjectHeadingType.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_subject_heading_type
    UserSession.create users(:librarian1)
    old_count = SubjectHeadingType.count
    delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_equal old_count, SubjectHeadingType.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_subject_heading_type
    UserSession.create users(:admin)
    old_count = SubjectHeadingType.count
    delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_equal old_count-1, SubjectHeadingType.count
    
    assert_redirected_to subject_heading_types_url
  end
end
