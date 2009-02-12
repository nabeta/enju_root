require File.dirname(__FILE__) + '/../test_helper'
require 'subjects_controller'

class SubjectsControllerTest < ActionController::TestCase
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
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:subjects)
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
  
  def test_guest_should_not_create_subject
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_subject
    login_as :user1
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subject
    login_as :librarian1
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_subject_without_term
    login_as :admin
    old_count = Subject.count
    post :create, :subject => { }
    assert_equal old_count, Subject.count
    
    assert_response :success
  end

  def test_admin_should_create_subject
    login_as :admin
    old_count = Subject.count
    post :create, :subject => {:term => 'test', :subject_type_id => 1}
    assert_equal old_count+1, Subject.count
    
    assert_redirected_to subject_url(assigns(:subject))
  end

  def test_guest_should_show_subject
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_show_subject_with_manifestation
    get :show, :id => 1, :manifestation_id => 1
    assert_response :success
    assert assigns(:subject)
    assert assigns(:manifestation)
  end

  def test_user_should_show_subject
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_subject
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_subject
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
  
  def test_admin_should_get_edit_with_manifestation
    login_as :admin
    get :edit, :id => 1, :manifestation_id => 1
    assert_response :success
  end
  
  def test_admin_should_not_get_edit_with_missing_manifestation
    login_as :admin
    get :edit, :id => 1, :manifestation_id => 100
    assert_response :missing
  end
  
  def test_guest_should_not_update_subject
    put :update, :id => 1, :subject => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_subject
    login_as :user1
    put :update, :id => 1, :subject => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subject
    login_as :librarian1
    put :update, :id => 1, :subject => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_subject_without_term
    login_as :admin
    put :update, :id => 1, :subject => {:term => nil}
    assert_response :success
  end
  
  def test_admin_should_update_subject
    login_as :admin
    put :update, :id => 1, :subject => { }
    assert_redirected_to subject_url(assigns(:subject))
  end
  
  def test_guest_should_not_destroy_subject
    old_count = Subject.count
    delete :destroy, :id => 1
    assert_equal old_count, Subject.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_subject
    login_as :user1
    old_count = Subject.count
    delete :destroy, :id => 1
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_subject
    login_as :librarian1
    old_count = Subject.count
    delete :destroy, :id => 1
    assert_equal old_count, Subject.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_subject
    login_as :admin
    old_count = Subject.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Subject.count
    
    assert_redirected_to subjects_url
  end
end
