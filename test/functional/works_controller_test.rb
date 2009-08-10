require 'test_helper'

class WorksControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :works, :work_forms, :expressions, :realizes, :creates, :produces, :reifies,
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
    UserSession.create(User.find(1))
    #UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:works)
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
    assert_response :success
  end
  
  def test_admin_should_get_new
    UserSession.create users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_work
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work
    UserSession.create users(:user1)
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_without_title
    UserSession.create users(:librarian1)
    old_count = Work.count
    post :create, :work => { :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_response :success
  end

  def test_librarian_should_create_work_without_work_form_id
    UserSession.create users(:librarian1)
    old_count = Work.count
    post :create, :work => { :original_title => 'test' }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_librarian_should_create_work
    UserSession.create users(:librarian1)
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_admin_should_create_work
    UserSession.create users(:admin)
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
    assigns(:work).remove_from_index!
  end

  def test_guest_should_show_work
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_work
    UserSession.create users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_work
    put :update, :id => 1, :work => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_work
    UserSession.create users(:user1)
    put :update, :id => 1, :work => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_without_title
    UserSession.create users(:librarian1)
    put :update, :id => 1, :work => {:original_title => "", :work_form_id => 1}
    assert_response :success
  end
  
  def test_librarian_should_not_update_work_without_work_form_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :work => {:work_form_id => nil, :original_title => 'test'}
    assert_response :success
  end
  
  def test_librarian_should_update_work
    UserSession.create users(:librarian1)
    put :update, :id => 1, :work => { }
    assert_redirected_to work_url(assigns(:work))
    assigns(:work).remove_from_index!
  end
  
  def test_admin_should_update_work
    UserSession.create users(:admin)
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
    UserSession.create users(:user1)
    assert_no_difference('Work.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_work
    UserSession.create users(:librarian1)
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end

  def test_admin_should_destroy_work
    UserSession.create users(:admin)
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end
end
