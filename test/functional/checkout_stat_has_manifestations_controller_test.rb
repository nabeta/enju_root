require 'test_helper'

class CheckoutStatHasManifestationsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :checkout_stat_has_manifestations, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:checkout_stat_has_manifestations)
  end

  test "user should not get index" do
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:checkout_stat_has_manifestations)
  end

  test "librarian should get index" do
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:checkout_stat_has_manifestations)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    UserSession.create users(:user1)
    get :new
    assert_response :forbidden
  end

  test "should get new" do
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create checkout_stat_has_manifestation" do
    assert_no_difference('CheckoutStatHasManifestation.count') do
      post :create, :checkout_stat_has_manifestation => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create checkout_stat_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('CheckoutStatHasManifestation.count') do
      post :create, :checkout_stat_has_manifestation => { }
    end

    assert_response :forbidden
  end

  test "librarian should create checkout_stat_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('CheckoutStatHasManifestation.count') do
      post :create, :checkout_stat_has_manifestation => { }
    end

    assert_redirected_to checkout_stat_has_manifestation_path(assigns(:checkout_stat_has_manifestation))
  end

  test "guest should not show checkout_stat_has_manifestation" do
    get :show, :id => checkout_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show checkout_stat_has_manifestation" do
    UserSession.create users(:user1)
    get :show, :id => checkout_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should show checkout_stat_has_manifestation" do
    UserSession.create users(:librarian1)
    get :show, :id => checkout_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => checkout_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    UserSession.create users(:user1)
    get :edit, :id => checkout_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    UserSession.create users(:librarian1)
    get :edit, :id => checkout_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not update checkout_stat_has_manifestation" do
    put :update, :id => checkout_stat_has_manifestations(:one).id, :checkout_stat_has_manifestation => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update checkout_stat_has_manifestation" do
    UserSession.create users(:user1)
    put :update, :id => checkout_stat_has_manifestations(:one).id, :checkout_stat_has_manifestation => { }
    assert_response :forbidden
  end

  test "librarian should update checkout_stat_has_manifestation" do
    UserSession.create users(:librarian1)
    put :update, :id => checkout_stat_has_manifestations(:one).id, :checkout_stat_has_manifestation => {:manifestation_checkout_stat_id => 1, :manifestation_id => 2}
    assert_redirected_to checkout_stat_has_manifestation_path(assigns(:checkout_stat_has_manifestation))
  end

  test "guest should not destroy checkout_stat_has_manifestation" do
    assert_no_difference('CheckoutStatHasManifestation.count') do
      delete :destroy, :id => checkout_stat_has_manifestations(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy checkout_stat_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('CheckoutStatHasManifestation.count') do
      delete :destroy, :id => checkout_stat_has_manifestations(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy checkout_stat_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('CheckoutStatHasManifestation.count', -1) do
      delete :destroy, :id => checkout_stat_has_manifestations(:one).id
    end

    assert_redirected_to checkout_stat_has_manifestations_path
  end
end
