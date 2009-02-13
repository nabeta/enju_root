require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  fixtures :subscriptions, :users, :patrons, :patron_types, :languages, :roles

  def test_guest_should_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:subscriptions)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:subscriptions)
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
  
  def test_guest_should_not_create_subscription
    old_count = Subscription.count
    post :create, :subscription => { :title => 'test' }
    assert_equal old_count, Subscription.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_subscription
    login_as :user1
    old_count = Subscription.count
    post :create, :subscription => { :title => 'test' }
    assert_equal old_count, Subscription.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subscription_without_title
    login_as :librarian1
    old_count = Subscription.count
    post :create, :subscription => { }
    assert_equal old_count, Subscription.count
    
    assert_response :success
  end

  def test_librarian_should_create_subscription
    login_as :librarian1
    old_count = Subscription.count
    post :create, :subscription => { :title => 'test' }
    assert_equal old_count+1, Subscription.count
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end

  def test_admin_should_create_subscription
    login_as :admin
    old_count = Subscription.count
    post :create, :subscription => { :title => 'test' }
    assert_equal old_count+1, Subscription.count
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end

  def test_guest_should_not_show_subscription
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_subscription
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_subscription
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_subscription
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
  
  def test_guest_should_not_update_subscription
    put :update, :id => 1, :subscription => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_subscription
    login_as :user1
    put :update, :id => 1, :subscription => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subscription_without_title
    login_as :librarian1
    put :update, :id => 1, :subscription => {:title => ""}
    assert_response :success
  end
  
  def test_librarian_should_update_subscription
    login_as :librarian1
    put :update, :id => 1, :subscription => { }
    assert_redirected_to subscription_url(assigns(:subscription))
  end
  
  def test_admin_should_update_subscription
    login_as :admin
    put :update, :id => 1, :subscription => { }
    assert_redirected_to subscription_url(assigns(:subscription))
  end
  
  def test_guest_should_not_destroy_subscription
    old_count = Subscription.count
    delete :destroy, :id => 1
    assert_equal old_count, Subscription.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_subscription
    login_as :user1
    old_count = Subscription.count
    delete :destroy, :id => 1
    assert_equal old_count, Subscription.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_subscription
    login_as :librarian1
    old_count = Subscription.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Subscription.count
    
    assert_redirected_to subscriptions_url
  end

  def test_admin_should_destroy_subscription
    login_as :admin
    old_count = Subscription.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Subscription.count
    
    assert_redirected_to subscriptions_url
  end
end
