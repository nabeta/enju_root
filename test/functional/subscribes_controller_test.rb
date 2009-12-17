require 'test_helper'

class SubscribesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :subscribes, :subscriptions, :users, :patrons, :patron_types,
    :languages, :roles, :works, :carrier_types, :manifestations, :form_of_works

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subscribes)
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
  
  def test_guest_should_not_create_subscribe
    old_count = Subscribe.count
    post :create, :subscribe => { :work_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subscribe
    UserSession.create users(:user1)
    old_count = Subscribe.count
    post :create, :subscribe => { :work_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_create_without_work_id
    UserSession.create users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_without_subscription_id
    UserSession.create users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :work_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_already_created
    UserSession.create users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :started_on => Date.today.to_s, :ended_on => Date.tomorrow.to_s, :work_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_create_subscribe_not_created_yet
    UserSession.create users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :started_on => Date.today.to_s, :ended_on => Date.tomorrow.to_s, :work_id => 3, :subscription_id => 1 }
    assert_equal old_count+1, Subscribe.count
    
    assert_redirected_to subscribe_url(assigns(:subscribe))
  end

  def test_guest_should_not_show_subscribe
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_subscribe
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_subscribe
    UserSession.create users(:librarian1)
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
    get :edit, :id => 1, :work_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1, :work_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_subscribe
    put :update, :id => 1, :subscribe => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subscribe
    UserSession.create users(:user1)
    put :update, :id => 1, :subscribe => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_create_without_work_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :subscribe => {:work_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_create_without_subscription_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :subscribe => {:subscription_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_subscribe
    UserSession.create users(:librarian1)
    put :update, :id => 1, :subscribe => { }
    assert_redirected_to subscribe_url(assigns(:subscribe))
  end
  
  def test_guest_should_not_destroy_subscribe
    old_count = Subscribe.count
    delete :destroy, :id => 1
    assert_equal old_count, Subscribe.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subscribe
    UserSession.create users(:user1)
    old_count = Subscribe.count
    delete :destroy, :id => 1
    assert_equal old_count, Subscribe.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_subscribe
    UserSession.create users(:librarian1)
    old_count = Subscribe.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Subscribe.count
    
    assert_redirected_to subscribes_url
  end
end
