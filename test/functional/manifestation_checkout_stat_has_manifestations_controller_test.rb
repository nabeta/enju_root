require 'test_helper'

class ManifestationCheckoutStatHasManifestationsControllerTest < ActionController::TestCase
  fixtures :manifestation_checkout_stat_has_manifestations, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:manifestation_checkout_stat_has_manifestations)
  end

  test "user should not get index" do
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:manifestation_checkout_stat_has_manifestations)
  end

  test "librarian should get index" do
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_checkout_stat_has_manifestations)
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

  test "guest should not create manifestation_checkout_stat_has_manifestation" do
    assert_no_difference('ManifestationCheckoutStatHasManifestation.count') do
      post :create, :manifestation_checkout_stat_has_manifestation => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create manifestation_checkout_stat_has_manifestation" do
    login_as :user1
    assert_no_difference('ManifestationCheckoutStatHasManifestation.count') do
      post :create, :manifestation_checkout_stat_has_manifestation => { }
    end

    assert_response :forbidden
  end

  test "librarian should create manifestation_checkout_stat_has_manifestation" do
    login_as :librarian1
    assert_difference('ManifestationCheckoutStatHasManifestation.count') do
      post :create, :manifestation_checkout_stat_has_manifestation => { }
    end

    assert_redirected_to manifestation_checkout_stat_has_manifestation_path(assigns(:manifestation_checkout_stat_has_manifestation))
  end

  test "guest should not show manifestation_checkout_stat_has_manifestation" do
    get :show, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not show manifestation_checkout_stat_has_manifestation" do
    login_as :user1
    get :show, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should show manifestation_checkout_stat_has_manifestation" do
    login_as :librarian1
    get :show, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => manifestation_checkout_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not update manifestation_checkout_stat_has_manifestation" do
    put :update, :id => manifestation_checkout_stat_has_manifestations(:one).id, :manifestation_checkout_stat_has_manifestation => { }
    assert_redirected_to new_session_url
  end

  test "user should not update manifestation_checkout_stat_has_manifestation" do
    login_as :user1
    put :update, :id => manifestation_checkout_stat_has_manifestations(:one).id, :manifestation_checkout_stat_has_manifestation => { }
    assert_response :forbidden
  end

  test "librarian should update manifestation_checkout_stat_has_manifestation" do
    login_as :librarian1
    put :update, :id => manifestation_checkout_stat_has_manifestations(:one).id, :manifestation_checkout_stat_has_manifestation => {:manifestation_checkout_stat_id => 1, :manifestation_id => 2}
    assert_redirected_to manifestation_checkout_stat_has_manifestation_path(assigns(:manifestation_checkout_stat_has_manifestation))
  end

  test "guest should not destroy manifestation_checkout_stat_has_manifestation" do
    assert_no_difference('ManifestationCheckoutStatHasManifestation.count') do
      delete :destroy, :id => manifestation_checkout_stat_has_manifestations(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy manifestation_checkout_stat_has_manifestation" do
    login_as :user1
    assert_no_difference('ManifestationCheckoutStatHasManifestation.count') do
      delete :destroy, :id => manifestation_checkout_stat_has_manifestations(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy manifestation_checkout_stat_has_manifestation" do
    login_as :librarian1
    assert_difference('ManifestationCheckoutStatHasManifestation.count', -1) do
      delete :destroy, :id => manifestation_checkout_stat_has_manifestations(:one).id
    end

    assert_redirected_to manifestation_checkout_stat_has_manifestations_path
  end
end
