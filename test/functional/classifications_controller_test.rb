require File.dirname(__FILE__) + '/../test_helper'
require 'classifications_controller'

class ClassificationsControllerTest < ActionController::TestCase
  fixtures :classifications, :classification_types, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:classifications)
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
  
  def test_guest_should_not_create_classification
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_classification
    login_as :user1
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_classification
    login_as :librarian1
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_classification_without_name
    login_as :admin
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_response :success
  end

  def test_admin_should_create_classification
    login_as :admin
    old_count = Classification.count
    post :create, :classification => {:category => '000.0', :name => 'test', :classification_type_id => '1'}
    assert_equal old_count+1, Classification.count
    
    assert_redirected_to classification_url(assigns(:classification))
  end

  def test_admin_should_not_create_classification_already_created
    login_as :admin
    old_count = Classification.count
    post :create, :classification => {:category => '000', :name => 'test', :classification_type_id => '1'}
    assert_equal old_count, Classification.count
    
    assert_response :success
  end

  def test_guest_should_show_classification
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_classification
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_classification
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_classification
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
  
  def test_guest_should_not_update_classification
    put :update, :id => 1, :classification => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_classification
    login_as :user1
    put :update, :id => 1, :classification => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_classification
    login_as :librarian1
    put :update, :id => 1, :classification => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_classification_without_name
    login_as :admin
    put :update, :id => 1, :classification => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_classification
    login_as :admin
    put :update, :id => 1, :classification => { }
    assert_redirected_to classification_url(assigns(:classification))
  end
  
  def test_guest_should_not_destroy_classification
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_classification
    login_as :user1
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_classification
    login_as :librarian1
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_classification
    login_as :admin
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Classification.count
    
    assert_redirected_to classifications_url
  end
end
