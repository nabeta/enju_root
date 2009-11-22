require 'test_helper'

class WorkToExpressionRelTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_to_expression_rel_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_to_expression_rel_type" do
    assert_difference('WorkToExpressionRelType.count') do
      post :create, :work_to_expression_rel_type => { }
    end

    assert_redirected_to work_to_expression_rel_type_path(assigns(:work_to_expression_rel_type))
  end

  test "should show work_to_expression_rel_type" do
    get :show, :id => work_to_expression_rel_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => work_to_expression_rel_types(:one).to_param
    assert_response :success
  end

  test "should update work_to_expression_rel_type" do
    put :update, :id => work_to_expression_rel_types(:one).to_param, :work_to_expression_rel_type => { }
    assert_redirected_to work_to_expression_rel_type_path(assigns(:work_to_expression_rel_type))
  end

  test "should destroy work_to_expression_rel_type" do
    assert_difference('WorkToExpressionRelType.count', -1) do
      delete :destroy, :id => work_to_expression_rel_types(:one).to_param
    end

    assert_redirected_to work_to_expression_rel_types_path
  end
end
