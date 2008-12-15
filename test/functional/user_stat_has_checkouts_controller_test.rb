require 'test_helper'

class UserStatHasCheckoutsControllerTest < ActionController::TestCase
  fixtures :user_stat_has_checkouts, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:user_stat_has_checkouts)
  end

  test "user should not get index" do
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:user_stat_has_checkouts)
  end

  test "librarian should get index" do
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:user_stat_has_checkouts)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get new" do
    login_as :user1
    get :new
    assert_response :forbidden
  end

  test "should get new" do
    login_as :librarian1
    get :new
    assert_response :success
  end

  test "guest should not create user_stat_has_checkout" do
    assert_no_difference('UserStatHasCheckout.count') do
      post :create, :user_stat_has_checkout => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create user_stat_has_checkout" do
    login_as :user1
    assert_no_difference('UserStatHasCheckout.count') do
      post :create, :user_stat_has_checkout => { }
    end

    assert_response :forbidden
  end

  test "librarian should create user_stat_has_checkout" do
    login_as :librarian1
    assert_difference('UserStatHasCheckout.count') do
      post :create, :user_stat_has_checkout => { }
    end

    assert_redirected_to user_stat_has_checkout_path(assigns(:user_stat_has_checkout))
  end

  test "guest should not show user_stat_has_checkout" do
    get :show, :id => user_stat_has_checkouts(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not show user_stat_has_checkout" do
    login_as :user1
    get :show, :id => user_stat_has_checkouts(:one).id
    assert_response :forbidden
  end

  test "librarian should show user_stat_has_checkout" do
    login_as :librarian1
    get :show, :id => user_stat_has_checkouts(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => user_stat_has_checkouts(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => user_stat_has_checkouts(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => user_stat_has_checkouts(:one).id
    assert_response :success
  end

  test "guest should not update user_stat_has_checkout" do
    put :update, :id => user_stat_has_checkouts(:one).id, :user_stat_has_checkout => { }
    assert_redirected_to new_session_url
  end

  test "user should not update user_stat_has_checkout" do
    login_as :user1
    put :update, :id => user_stat_has_checkouts(:one).id, :user_stat_has_checkout => { }
    assert_response :forbidden
  end

  test "librarian should update user_stat_has_checkout" do
    login_as :librarian1
    put :update, :id => user_stat_has_checkouts(:one).id, :user_stat_has_checkout => { }
    assert_redirected_to user_stat_has_checkout_path(assigns(:user_stat_has_checkout))
  end

  test "guest should not destroy user_stat_has_checkout" do
    assert_no_difference('UserStatHasCheckout.count') do
      delete :destroy, :id => user_stat_has_checkouts(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy user_stat_has_checkout" do
    login_as :user1
    assert_no_difference('UserStatHasCheckout.count') do
      delete :destroy, :id => user_stat_has_checkouts(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy user_stat_has_checkout" do
    login_as :librarian1
    assert_difference('UserStatHasCheckout.count', -1) do
      delete :destroy, :id => user_stat_has_checkouts(:one).id
    end

    assert_redirected_to user_stat_has_checkouts_path
  end
end
