require 'test_helper'

class ExpressionToManifestationRelTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_to_manifestation_rel_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expression_to_manifestation_rel_type" do
    assert_difference('ExpressionToManifestationRelType.count') do
      post :create, :expression_to_manifestation_rel_type => { }
    end

    assert_redirected_to expression_to_manifestation_rel_type_path(assigns(:expression_to_manifestation_rel_type))
  end

  test "should show expression_to_manifestation_rel_type" do
    get :show, :id => expression_to_manifestation_rel_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => expression_to_manifestation_rel_types(:one).to_param
    assert_response :success
  end

  test "should update expression_to_manifestation_rel_type" do
    put :update, :id => expression_to_manifestation_rel_types(:one).to_param, :expression_to_manifestation_rel_type => { }
    assert_redirected_to expression_to_manifestation_rel_type_path(assigns(:expression_to_manifestation_rel_type))
  end

  test "should destroy expression_to_manifestation_rel_type" do
    assert_difference('ExpressionToManifestationRelType.count', -1) do
      delete :destroy, :id => expression_to_manifestation_rel_types(:one).to_param
    end

    assert_redirected_to expression_to_manifestation_rel_types_path
  end
end
