require 'test_helper'

class PurchaseRequestsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :purchase_requests, :users, :order_lists, :orders

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:purchase_requests)
  end

  def test_user_should_get_my_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert_not_nil assigns(:purchase_requests)
  end

  def test_user_should_get_my_index_csv
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:purchase_requests)
  end

  def test_user_should_get_my_index_rss
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert_not_nil assigns(:purchase_requests)
  end

  def test_user_should_not_get_other_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:librarian1).login
    assert_response :forbidden
    assert_nil assigns(:purchase_requests)
  end

  def test_librarian_should_get_other_index_without_user_id
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_requests)
  end

  def test_guest_should_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_get_other_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:user2).login
    assert_response :forbidden
  end

  def test_librarian_should_get_new_without_user_id
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_purchase_request
    assert_no_difference('PurchaseRequest.count') do
      post :create, :purchase_request => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_create_purchase_request_without_user_id
    UserSession.create users(:user1)
    assert_difference('PurchaseRequest.count') do
      post :create, :purchase_request => {:title => 'test', :user_id => users(:user1).id}
    end

    assert_redirected_to user_purchase_request_url(users(:user1).login, assigns(:purchase_request))
  end

  def test_user_should_not_create_purchase_request_without_title
    UserSession.create users(:user1)
    assert_no_difference('PurchaseRequest.count') do
      post :create, :purchase_request => { }, :user_id => users(:user1).login
    end

    assert_response :success
  end

  def test_user_should_create_purchase_request
    UserSession.create users(:user1)
    assert_difference('PurchaseRequest.count') do
      post :create, :purchase_request => {:title => 'test', :user_id => users(:user1).id}, :user_id => users(:user1).login
    end

    assert_redirected_to user_purchase_request_url(users(:user1).login, assigns(:purchase_request))
  end

  def test_librarian_should_create_purchase_request_without_user_id
    UserSession.create users(:librarian1)
    assert_difference('PurchaseRequest.count') do
      post :create, :purchase_request => {:title => 'test', :user_id => users(:user1).id}
    end

    assert_redirected_to user_purchase_request_url(users(:librarian1).login, assigns(:purchase_request))
  end

  def test_guest_should_not_show_purchase_request
    get :show, :id => purchase_requests(:purchase_request_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_my_purchase_request
    UserSession.create users(:user1)
    get :show, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_show_other_purchase_request
    UserSession.create users(:user1)
    get :show, :id => purchase_requests(:purchase_request_00002).id, :user_id => users(:librarian1).login
    assert_response :forbidden
  end

  def test_librarian_should_show_purchase_request_without_user_id
    UserSession.create users(:librarian1)
    get :show, :id => purchase_requests(:purchase_request_00002).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => purchase_requests(:purchase_request_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_edit
    UserSession.create users(:user1)
    get :edit, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_get_other_edit
    UserSession.create users(:user1)
    get :edit, :id => purchase_requests(:purchase_request_00002).id, :user_id => users(:librarian1).login
    assert_response :forbidden
  end

  def test_librarian_should_get_edit_without_user_id
    UserSession.create users(:librarian1)
    get :edit, :id => purchase_requests(:purchase_request_00002).id
    assert_response :success
  end

  def test_guest_should_not_update_purchase_request
    put :update, :id => purchase_requests(:purchase_request_00003).id, :purchase_request => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_update_my_purchase_request
    UserSession.create users(:user1)
    put :update, :id => purchase_requests(:purchase_request_00003).id, :purchase_request => { }, :user_id => users(:user1).login
    assert_redirected_to user_purchase_request_url(users(:user1).login, assigns(:purchase_request))
  end

  def test_user_should_not_update_other_purchase_request
    UserSession.create users(:user1)
    put :update, :id => purchase_requests(:purchase_request_00002).id, :purchase_request => { }, :user_id => users(:librarian1).login
    assert_response :forbidden
  end

  def test_librarian_should_update_purchase_request_without_user_id
    UserSession.create users(:librarian1)
    put :update, :id => purchase_requests(:purchase_request_00002).id, :purchase_request => { }
    assert_redirected_to purchase_request_url(assigns(:purchase_request))
  end

  def test_user_should_not_update_purchase_request_without_title
    UserSession.create users(:user1)
    put :update, :id => purchase_requests(:purchase_request_00003).id, :purchase_request => {:title => ""}, :user_id => users(:user1).login
    assert_response :success
  end

  def test_librarian_should_update_purchase_request_without_user_id
    UserSession.create users(:librarian1)
    put :update, :id => purchase_requests(:purchase_request_00003).id, :purchase_request => { }
    assert_redirected_to user_purchase_request_url(users(:user1).login, assigns(:purchase_request))
  end

  def test_guest_should_not_destroy_purchase_request
    assert_no_difference('PurchaseRequest.count') do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_purchase_request
    UserSession.create users(:user1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).login
    end

    assert_redirected_to user_purchase_requests_url(users(:user1).login)
  end

  def test_user_should_not_destroy_other_purchase_request
    UserSession.create users(:user1)
    assert_no_difference('PurchaseRequest.count') do
      delete :destroy, :id => purchase_requests(:purchase_request_00002).id, :user_id => users(:librarian1).login
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_other_purchase_request
    UserSession.create users(:librarian1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).login
    end

    assert_redirected_to purchase_requests_url
  end

  def test_librarian_should_destroy_purchase_request_without_user_id
    UserSession.create users(:librarian1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id
    end

    assert_redirected_to purchase_requests_url
  end
end
