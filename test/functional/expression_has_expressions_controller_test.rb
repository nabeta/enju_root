require 'test_helper'

class ExpressionHasExpressionsControllerTest < ActionController::TestCase
  fixtures :expression_has_expressions

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_has_expressions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expression_has_expression" do
    assert_difference('ExpressionHasExpression.count') do
      post :create, :expression_has_expression => { }
    end

    assert_redirected_to expression_has_expression_path(assigns(:expression_has_expression))
  end

  test "should show expression_has_expression" do
    get :show, :id => expression_has_expressions(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => expression_has_expressions(:one).id
    assert_response :success
  end

  test "should update expression_has_expression" do
    put :update, :id => expression_has_expressions(:one).id, :expression_has_expression => { }
    assert_redirected_to expression_has_expression_path(assigns(:expression_has_expression))
  end

  test "should destroy expression_has_expression" do
    assert_difference('ExpressionHasExpression.count', -1) do
      delete :destroy, :id => expression_has_expressions(:one).id
    end

    assert_redirected_to expression_has_expressions_path
  end
end
