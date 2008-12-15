require 'test_helper'

class UserStatsControllerTest < ActionController::TestCase
  fixtures :user_stats, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_stats)
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

  test "librarian should get new" do
    login_as :librarian1
    get :new
    assert_response :success
  end

  test "guest should not create user_stat" do
    assert_no_difference('UserStat.count') do
      post :create, :user_stat => { }
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not create user_stat" do
    login_as :user1
    assert_no_difference('UserStat.count') do
      post :create, :user_stat => { }
    end

    assert_response :forbidden
  end

  test "librarian should create user_stat" do
    login_as :librarian1
    assert_difference('UserStat.count') do
      post :create, :user_stat => { }
    end

    assert_redirected_to user_stat_path(assigns(:user_stat))
  end

  test "guest should show user_stat" do
    get :show, :id => user_stats(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => user_stats(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => user_stats(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => user_stats(:one).id
    assert_response :success
  end

  test "guest should not update user_stat" do
    put :update, :id => user_stats(:one).id, :user_stat => { }
    assert_redirected_to new_session_url
  end

  test "user should not update user_stat" do
    login_as :user1
    put :update, :id => user_stats(:one).id, :user_stat => { }
    assert_response :forbidden
  end

  test "librarian should update user_stat" do
    login_as :librarian1
    put :update, :id => user_stats(:one).id, :user_stat => { }
    assert_redirected_to user_stat_path(assigns(:user_stat))
  end

  test "guest_should not destroy user_stat" do
    assert_no_difference('UserStat.count') do
      delete :destroy, :id => user_stats(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy user_stat" do
    login_as :user1
    assert_no_difference('UserStat.count') do
      delete :destroy, :id => user_stats(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy user_stat" do
    login_as :librarian1
    assert_difference('UserStat.count', -1) do
      delete :destroy, :id => user_stats(:one).id
    end

    assert_redirected_to user_stats_path
  end
end
