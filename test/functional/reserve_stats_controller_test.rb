require 'test_helper'

class ReserveStatsControllerTest < ActionController::TestCase
  fixtures :reserve_stats, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reserve_stats)
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

  test "guest should not create reserve_stat" do
    assert_no_difference('ReserveStat.count') do
      post :create, :reserve_stat => { }
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not create reserve_stat" do
    login_as :user1
    assert_no_difference('ReserveStat.count') do
      post :create, :reserve_stat => { }
    end

    assert_response :forbidden
  end

  test "librarian should create reserve_stat" do
    login_as :librarian1
    assert_difference('ReserveStat.count') do
      post :create, :reserve_stat => { }
    end

    assert_redirected_to reserve_stat_path(assigns(:reserve_stat))
  end

  test "guest should show reserve_stat" do
    get :show, :id => reserve_stats(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => reserve_stats(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => reserve_stats(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => reserve_stats(:one).id
    assert_response :success
  end

  test "guest should not update reserve_stat" do
    put :update, :id => reserve_stats(:one).id, :reserve_stat => { }
    assert_redirected_to new_session_url
  end

  test "user should not update reserve_stat" do
    login_as :user1
    put :update, :id => reserve_stats(:one).id, :reserve_stat => { }
    assert_response :forbidden
  end

  test "librarian should update reserve_stat" do
    login_as :librarian1
    put :update, :id => reserve_stats(:one).id, :reserve_stat => { }
    assert_redirected_to reserve_stat_path(assigns(:reserve_stat))
  end

  test "guest_should not destroy reserve_stat" do
    assert_no_difference('ReserveStat.count') do
      delete :destroy, :id => reserve_stats(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy reserve_stat" do
    login_as :user1
    assert_no_difference('ReserveStat.count') do
      delete :destroy, :id => reserve_stats(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy reserve_stat" do
    login_as :librarian1
    assert_difference('ReserveStat.count', -1) do
      delete :destroy, :id => reserve_stats(:one).id
    end

    assert_redirected_to reserve_stats_path
  end
end
