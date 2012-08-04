require 'test_helper'

class WorksControllerTest < ActionController::TestCase
  fixtures :works, :form_of_works, :expressions, :realizes, :creates, :produces, :reifies,
    :patrons, :users, :roles

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:works)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:work)
    assert assigns(:works)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_work
    assert_no_difference('Work.count') do
      post :create, :work => { :original_title => 'test', :form_of_work_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work
    sign_in users(:user1)
    assert_no_difference('Work.count') do
      post :create, :work => { :original_title => 'test', :form_of_work_id => 1 }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_without_title
    sign_in users(:librarian1)
    assert_no_difference('Work.count') do
      post :create, :work => { :form_of_work_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_work_without_form_of_work_id
    sign_in users(:librarian1)
    assert_difference('Work.count') do
      post :create, :work => { :original_title => 'test' }
    end
    
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_librarian_should_create_work
    sign_in users(:librarian1)
    assert_difference('Work.count') do
      post :create, :work => { :original_title => 'test', :form_of_work_id => 1 }
    end
    
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_admin_should_create_work
    sign_in users(:admin)
    assert_difference('Work.count') do
      post :create, :work => { :original_title => 'test', :form_of_work_id => 1 }
    end
    
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_guest_should_show_work
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_work
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_work
    put :update, :id => 1, :work => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_work
    sign_in users(:user1)
    put :update, :id => 1, :work => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_without_title
    sign_in users(:librarian1)
    put :update, :id => 1, :work => {:original_title => "", :form_of_work_id => 1}
    assert_response :success
  end
  
  def test_librarian_should_not_update_work_without_form_of_work_id
    sign_in users(:librarian1)
    put :update, :id => 1, :work => {:form_of_work_id => nil, :original_title => 'test'}
    assert_response :success
  end
  
  def test_librarian_should_update_work
    sign_in users(:librarian1)
    put :update, :id => 1, :work => { }
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end
  
  def test_admin_should_update_work
    sign_in users(:admin)
    put :update, :id => 1, :work => { }
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end
  
  def test_guest_should_not_destroy_work
    assert_no_difference('Work.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_work
    sign_in users(:user1)
    assert_no_difference('Work.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_work
    sign_in users(:librarian1)
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end

  def test_admin_should_destroy_work
    sign_in users(:admin)
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end
end
