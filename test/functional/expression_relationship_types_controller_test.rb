require 'test_helper'

class ExpressionRelationshipTypesControllerTest < ActionController::TestCase
  fixtures :expression_relationship_types

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expression_relationship_type" do
    assert_difference('ExpressionRelationshipType.count') do
      post :create, :expression_relationship_type => { }
    end

    assert_redirected_to expression_relationship_type_path(assigns(:expression_relationship_type))
  end

  test "should show expression_relationship_type" do
    get :show, :id => expression_relationship_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => expression_relationship_types(:one).id
    assert_response :success
  end

  test "should update expression_relationship_type" do
    put :update, :id => expression_relationship_types(:one).id, :expression_relationship_type => { }
    assert_redirected_to expression_relationship_type_path(assigns(:expression_relationship_type))
  end

  test "should destroy expression_relationship_type" do
    assert_difference('ExpressionRelationshipType.count', -1) do
      delete :destroy, :id => expression_relationship_types(:one).id
    end

    assert_redirected_to expression_relationship_types_path
  end
end
