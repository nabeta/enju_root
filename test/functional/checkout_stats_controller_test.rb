require 'test_helper'

class CheckoutStatsControllerTest < ActionController::TestCase
  fixtures :checkout_stats, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checkout_stats)
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

  test "guest should not create checkout_stat" do
    assert_no_difference('CheckoutStat.count') do
      post :create, :checkout_stat => { }
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not create checkout_stat" do
    login_as :user1
    assert_no_difference('CheckoutStat.count') do
      post :create, :checkout_stat => { }
    end

    assert_response :forbidden
  end

  test "librarian should create checkout_stat" do
    login_as :librarian1
    assert_difference('CheckoutStat.count') do
      post :create, :checkout_stat => { }
    end

    assert_redirected_to checkout_stat_path(assigns(:checkout_stat))
  end

  test "guest should show checkout_stat" do
    get :show, :id => checkout_stats(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => checkout_stats(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => checkout_stats(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => checkout_stats(:one).id
    assert_response :success
  end

  test "guest should not update checkout_stat" do
    put :update, :id => checkout_stats(:one).id, :checkout_stat => { }
    assert_redirected_to new_session_url
  end

  test "user should not update checkout_stat" do
    login_as :user1
    put :update, :id => checkout_stats(:one).id, :checkout_stat => { }
    assert_response :forbidden
  end

  test "librarian should update checkout_stat" do
    login_as :librarian1
    put :update, :id => checkout_stats(:one).id, :checkout_stat => { }
    assert_redirected_to checkout_stat_path(assigns(:checkout_stat))
  end

  test "guest_should not destroy checkout_stat" do
    assert_no_difference('CheckoutStat.count') do
      delete :destroy, :id => checkout_stats(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy checkout_stat" do
    login_as :user1
    assert_no_difference('CheckoutStat.count') do
      delete :destroy, :id => checkout_stats(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy checkout_stat" do
    login_as :librarian1
    assert_difference('CheckoutStat.count', -1) do
      delete :destroy, :id => checkout_stats(:one).id
    end

    assert_redirected_to checkout_stats_path
  end
end
