require 'test_helper'

class UserCheckoutStatHasUsersControllerTest < ActionController::TestCase
  fixtures :user_checkout_stats, :user_checkout_stat_has_users, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:user_checkout_stat_has_users)
  end

  test "user should not get index" do
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:user_checkout_stat_has_users)
  end

  test "librarian should get index" do
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:user_checkout_stat_has_users)
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

  test "guest should not create user_checkout_stat_has_user" do
    assert_no_difference('UserCheckoutStatHasUser.count') do
      post :create, :user_checkout_stat_has_user => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create user_checkout_stat_has_user" do
    login_as :user1
    assert_no_difference('UserCheckoutStatHasUser.count') do
      post :create, :user_checkout_stat_has_user => { }
    end

    assert_response :forbidden
  end

  test "librarian should create user_checkout_stat_has_user" do
    login_as :librarian1
    assert_difference('UserCheckoutStatHasUser.count') do
      post :create, :user_checkout_stat_has_user => { }
    end

    assert_redirected_to user_checkout_stat_has_user_path(assigns(:user_checkout_stat_has_user))
  end

  test "guest should not show user_checkout_stat_has_user" do
    get :show, :id => user_checkout_stat_has_users(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not show user_checkout_stat_has_user" do
    login_as :user1
    get :show, :id => user_checkout_stat_has_users(:one).id
    assert_response :forbidden
  end

  test "librarian should show user_checkout_stat_has_user" do
    login_as :librarian1
    get :show, :id => user_checkout_stat_has_users(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => user_checkout_stat_has_users(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => user_checkout_stat_has_users(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => user_checkout_stat_has_users(:one).id
    assert_response :success
  end

  test "guest should not update user_checkout_stat_has_user" do
    put :update, :id => user_checkout_stat_has_users(:one).id, :user_checkout_stat_has_user => { }
    assert_redirected_to new_session_url
  end

  test "user should not update user_checkout_stat_has_user" do
    login_as :user1
    put :update, :id => user_checkout_stat_has_users(:one).id, :user_checkout_stat_has_user => { }
    assert_response :forbidden
  end

  test "librarian should update user_checkout_stat_has_user" do
    login_as :librarian1
    put :update, :id => user_checkout_stat_has_users(:one).id, :user_checkout_stat_has_user => {:user_checkout_stat_id => 1, :user_id => 2}
    assert_redirected_to user_checkout_stat_has_user_path(assigns(:user_checkout_stat_has_user))
  end

  test "guest should not destroy user_checkout_stat_has_user" do
    assert_no_difference('UserCheckoutStatHasUser.count') do
      delete :destroy, :id => user_checkout_stat_has_users(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy user_checkout_stat_has_user" do
    login_as :user1
    assert_no_difference('UserCheckoutStatHasUser.count') do
      delete :destroy, :id => user_checkout_stat_has_users(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy user_checkout_stat_has_user" do
    login_as :librarian1
    assert_difference('UserCheckoutStatHasUser.count', -1) do
      delete :destroy, :id => user_checkout_stat_has_users(:one).id
    end

    assert_redirected_to user_checkout_stat_has_users_path
  end
end
