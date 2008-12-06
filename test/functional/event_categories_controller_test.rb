require File.dirname(__FILE__) + '/../test_helper'
require 'event_categories_controller'

class EventCategoriesControllerTest < ActionController::TestCase
  fixtures :event_categories, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:event_categories)
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
  
  def test_guest_should_not_create_event_category
    old_count = EventCategory.count
    post :create, :event_category => { }
    assert_equal old_count, EventCategory.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_event_category
    login_as :user1
    old_count = EventCategory.count
    post :create, :event_category => { }
    assert_equal old_count, EventCategory.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_event_category
    login_as :librarian1
    old_count = EventCategory.count
    post :create, :event_category => { }
    assert_equal old_count, EventCategory.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_event_category_without_name
    login_as :admin
    old_count = EventCategory.count
    post :create, :event_category => { }
    assert_equal old_count, EventCategory.count
    
    assert_response :success
  end

  def test_admin_should_create_event_category
    login_as :admin
    old_count = EventCategory.count
    post :create, :event_category => {:name => 'test'}
    assert_equal old_count+1, EventCategory.count
    
    assert_redirected_to event_category_url(assigns(:event_category))
  end

  def test_guest_should_show_event_category
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_event_category
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_event_category
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_event_category
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
  
  def test_guest_should_not_update_event_category
    put :update, :id => 1, :event_category => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_event_category
    login_as :user1
    put :update, :id => 1, :event_category => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_event_category
    login_as :librarian1
    put :update, :id => 1, :event_category => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_event_category_without_name
    login_as :admin
    put :update, :id => 1, :event_category => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_event_category
    login_as :admin
    put :update, :id => 1, :event_category => { }
    assert_redirected_to event_category_url(assigns(:event_category))
  end
  
  def test_guest_should_not_destroy_event_category
    old_count = EventCategory.count
    delete :destroy, :id => 1
    assert_equal old_count, EventCategory.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_event_category
    login_as :user1
    old_count = EventCategory.count
    delete :destroy, :id => 1
    assert_equal old_count, EventCategory.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_event_category
    login_as :librarian1
    old_count = EventCategory.count
    delete :destroy, :id => 1
    assert_equal old_count, EventCategory.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_event_category
    login_as :admin
    old_count = EventCategory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, EventCategory.count
    
    assert_redirected_to event_categories_url
  end
end
