require 'test_helper'

class ManifestationHasManifestationsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :manifestation_has_manifestations, :manifestations, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_has_manifestations)
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

  test "librarian should get new" do
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create manifestation_has_manifestation" do
    assert_no_difference('ManifestationHasManifestation.count') do
      post :create, :manifestation_has_manifestation => {:from_manifestation_id => 1, :to_manifestation_id => 2}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create manifestation_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('ManifestationHasManifestation.count') do
      post :create, :manifestation_has_manifestation => {:from_manifestation_id => 1, :to_manifestation_id => 2}
    end

    assert_response :forbidden
  end

  test "librarian should create manifestation_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('ManifestationHasManifestation.count') do
      post :create, :manifestation_has_manifestation => {:from_manifestation_id => 1, :to_manifestation_id => 2}
    end

    assert_redirected_to manifestation_has_manifestation_path(assigns(:manifestation_has_manifestation))
  end

  test "should show manifestation_has_manifestation" do
    get :show, :id => manifestation_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => manifestation_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    UserSession.create users(:user1)
    get :edit, :id => manifestation_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    UserSession.create users(:librarian1)
    get :edit, :id => manifestation_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not update manifestation_has_manifestation" do
    put :update, :id => manifestation_has_manifestations(:one).id, :manifestation_has_manifestation => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update manifestation_has_manifestation" do
    UserSession.create users(:user1)
    put :update, :id => manifestation_has_manifestations(:one).id, :manifestation_has_manifestation => { }
    assert_response :forbidden
  end

  test "librarian should update manifestation_has_manifestation" do
    UserSession.create users(:librarian1)
    put :update, :id => manifestation_has_manifestations(:one).id, :manifestation_has_manifestation => { }
    assert_redirected_to manifestation_has_manifestation_path(assigns(:manifestation_has_manifestation))
  end

  test "guest should not destroy manifestation_has_manifestation" do
    assert_no_difference('ManifestationHasManifestation.count') do
      delete :destroy, :id => manifestation_has_manifestations(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy manifestation_has_manifestation" do
    UserSession.create users(:user1)
    assert_no_difference('ManifestationHasManifestation.count') do
      delete :destroy, :id => manifestation_has_manifestations(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy manifestation_has_manifestation" do
    UserSession.create users(:librarian1)
    assert_difference('ManifestationHasManifestation.count', -1) do
      delete :destroy, :id => manifestation_has_manifestations(:one).id
    end

    assert_redirected_to manifestation_has_manifestations_path
  end
end
