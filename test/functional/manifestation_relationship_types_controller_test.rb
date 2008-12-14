require 'test_helper'

class ManifestationRelationshipTypesControllerTest < ActionController::TestCase
  fixtures :manifestation_relationship_types

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manifestation_relationship_type" do
    assert_difference('ManifestationRelationshipType.count') do
      post :create, :manifestation_relationship_type => { }
    end

    assert_redirected_to manifestation_relationship_type_path(assigns(:manifestation_relationship_type))
  end

  test "should show manifestation_relationship_type" do
    get :show, :id => manifestation_relationship_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => manifestation_relationship_types(:one).id
    assert_response :success
  end

  test "should update manifestation_relationship_type" do
    put :update, :id => manifestation_relationship_types(:one).id, :manifestation_relationship_type => { }
    assert_redirected_to manifestation_relationship_type_path(assigns(:manifestation_relationship_type))
  end

  test "should destroy manifestation_relationship_type" do
    assert_difference('ManifestationRelationshipType.count', -1) do
      delete :destroy, :id => manifestation_relationship_types(:one).id
    end

    assert_redirected_to manifestation_relationship_types_path
  end
end
