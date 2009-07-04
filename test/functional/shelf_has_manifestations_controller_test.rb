require 'test_helper'

class ShelfHasManifestationsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :shelf_has_manifestations, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:shelf_has_manifestations)
  end

  test "user should not get index" do
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:shelf_has_manifestations)
  end

  test "librarian should get index" do
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:shelf_has_manifestations)
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

  test "guest should not create shelf_has_manifestation" do
    assert_no_difference('ShelfHasManifestation.count') do
      post :create, :shelf_has_manifestation => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create shelf_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('ShelfHasManifestation.count') do
      post :create, :shelf_has_manifestation => { }
    end

    assert_response :forbidden
  end

  test "librarian should create shelf_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('ShelfHasManifestation.count') do
      post :create, :shelf_has_manifestation => { }
    end

    assert_redirected_to shelf_has_manifestation_path(assigns(:shelf_has_manifestation))
  end

  test "guest should not show shelf_has_manifestation" do
    get :show, :id => shelf_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show shelf_has_manifestation" do
    UserSession.create users(:user1)
    get :show, :id => shelf_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should show shelf_has_manifestation" do
    UserSession.create users(:librarian1)
    get :show, :id => shelf_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => shelf_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    UserSession.create users(:user1)
    get :edit, :id => shelf_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    UserSession.create users(:librarian1)
    get :edit, :id => shelf_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not update shelf_has_manifestation" do
    put :update, :id => shelf_has_manifestations(:one).id, :shelf_has_manifestation => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update shelf_has_manifestation" do
    UserSession.create users(:user1)
    put :update, :id => shelf_has_manifestations(:one).id, :shelf_has_manifestation => { }
    assert_response :forbidden
  end

  test "librarian should update shelf_has_manifestation" do
    UserSession.create users(:librarian1)
    put :update, :id => shelf_has_manifestations(:one).id, :shelf_has_manifestation => {:shelf_id => 1, :manifestation_id => 2}
    assert_redirected_to shelf_has_manifestation_path(assigns(:shelf_has_manifestation))
  end

  test "guest should not destroy shelf_has_manifestation" do
    assert_no_difference('ShelfHasManifestation.count') do
      delete :destroy, :id => shelf_has_manifestations(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy shelf_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('ShelfHasManifestation.count') do
      delete :destroy, :id => shelf_has_manifestations(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy shelf_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('ShelfHasManifestation.count', -1) do
      delete :destroy, :id => shelf_has_manifestations(:one).id
    end

    assert_redirected_to shelf_has_manifestations_path
  end
end
