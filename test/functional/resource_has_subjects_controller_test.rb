require 'test_helper'

class ResourceHasSubjectsControllerTest < ActionController::TestCase
  fixtures :resource_has_subjects, :manifestations, :concepts, :places, :subject_heading_types, :users, :subjects, :subject_types

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:resource_has_subjects)
  end

  def test_guest_should_get_index_with_subject_id
    get :index, :subject_id => 1
    assert_response :success
    assert assigns(:resource_has_subjects)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:resource_has_subjects)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:resource_has_subjects)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:resource_has_subjects)
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
    assert_response :success
  end
  
  def test_guest_should_not_create_resource_has_subject
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => { :subject_id => 1, :work_id => 1 }
    assert_equal old_count, ResourceHasSubject.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_resource_has_subject
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => { :subject_id => 1, :work_id => 1 }
    assert_equal old_count, ResourceHasSubject.count
    
    assert_redirected_to new_session_url
  end

  def test_librarian_should_not_create_resource_has_subject_without_subject_id
    login_as :librarian1
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => { :work_id => 1 }
    assert_equal old_count, ResourceHasSubject.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_resource_has_subject_without_manifestation_id
    login_as :librarian1
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => { :subject_id => 1 }
    assert_equal old_count, ResourceHasSubject.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_resource_has_subject_already_created
    login_as :librarian1
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => {:subject_id => 1, :subjectable_id => 1, :subjectable_type => 'Manifestation'}
    #post :create, :resource_has_subject => { :subject_id => 1, :work_id => 1, :subject_type => 'Place' }
    assert_equal old_count, ResourceHasSubject.count
    
    assert_response :success
  end

  def test_librarian_should_create_resource_has_subject_not_created_yet
    login_as :librarian1
    old_count = ResourceHasSubject.count
    post :create, :resource_has_subject => {:subject_id => 2, :subjectable_id => 2, :subjectable_type => 'Manifestation'}
    #post :create, :resource_has_subject => { :subject_id => 1, :work_id => 1, :subject_type => 'Place' }
    assert_equal old_count+1, ResourceHasSubject.count
    
    assert_redirected_to resource_has_subject_url(assigns(:resource_has_subject))
  end

  def test_guest_should_show_resource_has_subject
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_resource_has_subject
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_resource_has_subject
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1, :subject_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1, :subject_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_resource_has_subject
    put :update, :id => 1, :resource_has_subject => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_resource_has_subject
    login_as :user1
    put :update, :id => 1, :resource_has_subject => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_resource_has_subject_without_subject_id
    login_as :librarian1
    put :update, :id => 1, :resource_has_subject => {:subject_id => nil}
    assert_response :success
  end
  
  #def test_librarian_should_not_update_resource_has_subject_without_work_id
  #  login_as :librarian1
  #  put :update, :id => 1, :resource_has_subject => {:work_id => nil}
  #  assert_response :success
  #end
  
  def test_librarian_should_update_resource_has_subject
    login_as :librarian1
    put :update, :id => 1, :resource_has_subject => { }
    assert_redirected_to resource_has_subject_url(assigns(:resource_has_subject))
  end
  
  #def test_librarian_should_update_resource_has_subject_with_position
  #  login_as :librarian1
  #  put :update, :id => 1, :resource_has_subject => { }, :manifestation_id => 1, :position => 1
  #  assert_redirected_to manifestation_resource_has_subjects_url(assigns(:manifestation))
  #end
  
  def test_guest_should_not_destroy_resource_has_subject
    old_count = ResourceHasSubject.count
    delete :destroy, :id => 1
    assert_equal old_count, ResourceHasSubject.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_resource_has_subject
    login_as :user1
    old_count = ResourceHasSubject.count
    delete :destroy, :id => 1
    assert_equal old_count, ResourceHasSubject.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_resource_has_subject
    login_as :librarian1
    old_count = ResourceHasSubject.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ResourceHasSubject.count
    
    assert_redirected_to resource_has_subjects_url
  end

  def test_librarian_should_destroy_resource_has_subject_with_subject_id
    login_as :librarian1
    old_count = ResourceHasSubject.count
    delete :destroy, :id => 1, :subject_id => 1
    assert_equal old_count-1, ResourceHasSubject.count
    
    assert_redirected_to subject_resource_has_subjects_url(assigns(:subject))
  end

  def test_librarian_should_destroy_resource_has_subject_with_manifestation_id
    login_as :librarian1
    old_count = ResourceHasSubject.count
    delete :destroy, :id => 1, :manifestation_id => 1
    assert_equal old_count-1, ResourceHasSubject.count
    
    assert_redirected_to manifestation_resource_has_subjects_url(assigns(:manifestation))
  end
end
