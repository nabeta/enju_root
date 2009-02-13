require 'test_helper'

class WorkFormsControllerTest < ActionController::TestCase
  fixtures :work_forms, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:work_forms)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:work_forms)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:work_forms)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:work_forms)
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
  
  def test_guest_should_not_create_work_form
    old_count = WorkForm.count
    post :create, :work_form => { }
    assert_equal old_count, WorkForm.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_work_form
    login_as :user1
    old_count = WorkForm.count
    post :create, :work_form => { }
    assert_equal old_count, WorkForm.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_form
    login_as :librarian1
    old_count = WorkForm.count
    post :create, :work_form => { }
    assert_equal old_count, WorkForm.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_work_form_without_name
    login_as :admin
    old_count = WorkForm.count
    post :create, :work_form => { }
    assert_equal old_count, WorkForm.count
    
    assert_response :success
  end

  def test_admin_should_create_work_form
    login_as :admin
    old_count = WorkForm.count
    post :create, :work_form => {:name => 'test'}
    assert_equal old_count+1, WorkForm.count
    
    assert_redirected_to work_form_url(assigns(:work_form))
  end

  def test_guest_should_show_work_form
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work_form
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work_form
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_work_form
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
  
  def test_guest_should_not_update_work_form
    put :update, :id => 1, :work_form => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_work_form
    login_as :user1
    put :update, :id => 1, :work_form => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_form
    login_as :librarian1
    put :update, :id => 1, :work_form => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_work_form_without_name
    login_as :admin
    put :update, :id => 1, :work_form => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_work_form
    login_as :admin
    put :update, :id => 1, :work_form => { }
    assert_redirected_to work_form_url(assigns(:work_form))
  end
  
  def test_guest_should_not_destroy_work_form
    old_count = WorkForm.count
    delete :destroy, :id => 1
    assert_equal old_count, WorkForm.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_work_form
    login_as :user1
    old_count = WorkForm.count
    delete :destroy, :id => 1
    assert_equal old_count, WorkForm.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_work_form
    login_as :librarian1
    old_count = WorkForm.count
    delete :destroy, :id => 1
    assert_equal old_count, WorkForm.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_work_form
    login_as :admin
    old_count = WorkForm.count
    delete :destroy, :id => 1
    assert_equal old_count-1, WorkForm.count
    
    assert_redirected_to work_forms_url
  end
end
