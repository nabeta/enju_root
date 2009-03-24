require 'test_helper'

class SubscribesControllerTest < ActionController::TestCase
  fixtures :subscribes, :subscriptions, :users, :patrons, :patron_types,
    :languages, :roles, :expressions, :expression_forms, :works, :work_forms

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    set_session_for users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    set_session_for users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subscribes)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    set_session_for users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    set_session_for users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_subscribe
    old_count = Subscribe.count
    post :create, :subscribe => { :expression_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subscribe
    set_session_for users(:user1)
    old_count = Subscribe.count
    post :create, :subscribe => { :expression_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_create_without_expression_id
    set_session_for users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_without_subscription_id
    set_session_for users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :expression_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_already_created
    set_session_for users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :start_on => Date.today.to_s, :end_on => Date.tomorrow.to_s, :expression_id => 1, :subscription_id => 1 }
    assert_equal old_count, Subscribe.count
    
    assert_response :success
  end

  def test_librarian_should_create_subscribe_not_created_yet
    set_session_for users(:librarian1)
    old_count = Subscribe.count
    post :create, :subscribe => { :start_on => Date.today.to_s, :end_on => Date.tomorrow.to_s, :expression_id => 3, :subscription_id => 1 }
    assert_equal old_count+1, Subscribe.count
    
    assert_redirected_to subscribe_url(assigns(:subscribe))
  end

  def test_guest_should_not_show_subscribe
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_subscribe
    set_session_for users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_subscribe
    set_session_for users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    set_session_for users(:user1)
    get :edit, :id => 1, :expression_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    set_session_for users(:librarian1)
    get :edit, :id => 1, :expression_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_subscribe
    put :update, :id => 1, :subscribe => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subscribe
    set_session_for users(:user1)
    put :update, :id => 1, :subscribe => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_create_without_expression_id
    set_session_for users(:librarian1)
    put :update, :id => 1, :subscribe => {:expression_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_create_without_subscription_id
    set_session_for users(:librarian1)
    put :update, :id => 1, :subscribe => {:subscription_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_subscribe
    set_session_for users(:librarian1)
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
    set_session_for users(:user1)
    old_count = Subscribe.count
    delete :destroy, :id => 1
    assert_equal old_count, Subscribe.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_subscribe
    set_session_for users(:librarian1)
    old_count = Subscribe.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Subscribe.count
    
    assert_redirected_to subscribes_url
  end
end
