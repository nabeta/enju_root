require 'test_helper'

class ManifestationHasManifestationsControllerTest < ActionController::TestCase
  fixtures :manifestation_has_manifestations

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_has_manifestations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manifestation_has_manifestation" do
    assert_difference('ManifestationHasManifestation.count') do
      post :create, :manifestation_has_manifestation => { }
    end

    assert_redirected_to manifestation_has_manifestation_path(assigns(:manifestation_has_manifestation))
  end

  test "should show manifestation_has_manifestation" do
    get :show, :id => manifestation_has_manifestations(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => manifestation_has_manifestations(:one).id
    assert_response :success
  end

  test "should update manifestation_has_manifestation" do
    put :update, :id => manifestation_has_manifestations(:one).id, :manifestation_has_manifestation => { }
    assert_redirected_to manifestation_has_manifestation_path(assigns(:manifestation_has_manifestation))
  end

  test "should destroy manifestation_has_manifestation" do
    assert_difference('ManifestationHasManifestation.count', -1) do
      delete :destroy, :id => manifestation_has_manifestations(:one).id
    end

    assert_redirected_to manifestation_has_manifestations_path
  end
end
