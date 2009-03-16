require 'test_helper'

class WorksControllerTest < ActionController::TestCase
  fixtures :works, :work_forms, :expressions, :realizes, :creates, :produces, :reifies
  fixtures :patrons, :users, :roles
  fixtures :people, :corporate_bodies, :families

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

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:works)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:works)
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
  
  def test_admin_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_work
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_work
    login_as :user1
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_without_title
    login_as :librarian1
    old_count = Work.count
    post :create, :work => { :work_form_id => 1 }
    assert_equal old_count, Work.count
    
    assert_response :success
  end

  def test_librarian_should_create_work_without_work_form_id
    login_as :librarian1
    old_count = Work.count
    post :create, :work => { :original_title => 'test' }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
  end

  def test_librarian_should_create_work
    login_as :librarian1
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
  end

  def test_admin_should_create_work
    login_as :admin
    old_count = Work.count
    post :create, :work => { :original_title => 'test', :work_form_id => 1 }
    assert_equal old_count+1, Work.count
    
    assert_redirected_to work_patrons_url(assigns(:work))
  end

  def test_guest_should_show_work
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_work
    login_as :admin
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
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_work
    put :update, :id => 1, :work => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_work
    login_as :user1
    put :update, :id => 1, :work => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_without_title
    login_as :librarian1
    put :update, :id => 1, :work => {:original_title => "", :work_form_id => 1}
    assert_response :success
  end
  
  def test_librarian_should_not_update_work_without_work_form_id
    login_as :librarian1
    put :update, :id => 1, :work => {:work_form_id => nil, :original_title => 'test'}
    assert_response :success
  end
  
  def test_librarian_should_update_work
    login_as :librarian1
    put :update, :id => 1, :work => { }
    assert_redirected_to work_url(assigns(:work))
  end
  
  def test_admin_should_update_work
    login_as :admin
    put :update, :id => 1, :work => { }
    assert_redirected_to work_url(assigns(:work))
  end
  
  def test_guest_should_not_destroy_work
    assert_no_difference('Work.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_work
    login_as :user1
    assert_no_difference('Work.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_work
    login_as :librarian1
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end

  def test_admin_should_destroy_work
    login_as :admin
    assert_difference('Work.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to works_url
  end
end
