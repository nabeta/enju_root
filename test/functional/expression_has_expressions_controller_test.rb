require 'test_helper'

class ExpressionHasExpressionsControllerTest < ActionController::TestCase
  fixtures :expression_has_expressions, :expressions, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_has_expressions)
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

  test "librarian should get new" do
    login_as :librarian1
    get :new
    assert_response :success
  end

  test "guest should not create expression_has_expression" do
    assert_no_difference('ExpressionHasExpression.count') do
      post :create, :expression_has_expression => {:from_expression_id => 1, :to_expression_id => 2}
    end

    assert_redirected_to new_session_url
  end

  test "user should not create expression_has_expression" do
    login_as :user1
    assert_no_difference('ExpressionHasExpression.count') do
      post :create, :expression_has_expression => {:from_expression_id => 1, :to_expression_id => 2}
    end

    assert_response :forbidden
  end

  test "librarian should create expression_has_expression" do
    login_as :librarian1
    assert_difference('ExpressionHasExpression.count') do
      post :create, :expression_has_expression => {:from_expression_id => 1, :to_expression_id => 2}
    end

    assert_redirected_to expression_has_expression_path(assigns(:expression_has_expression))
  end

  test "should show expression_has_expression" do
    get :show, :id => expression_has_expressions(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => expression_has_expressions(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => expression_has_expressions(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => expression_has_expressions(:one).id
    assert_response :success
  end

  test "guest should not update expression_has_expression" do
    put :update, :id => expression_has_expressions(:one).id, :expression_has_expression => { }
    assert_redirected_to new_session_url
  end

  test "user should not update expression_has_expression" do
    login_as :user1
    put :update, :id => expression_has_expressions(:one).id, :expression_has_expression => { }
    assert_response :forbidden
  end

  test "librarian should update expression_has_expression" do
    login_as :librarian1
    put :update, :id => expression_has_expressions(:one).id, :expression_has_expression => { }
    assert_redirected_to expression_has_expression_path(assigns(:expression_has_expression))
  end

  test "guest should not destroy expression_has_expression" do
    assert_no_difference('ExpressionHasExpression.count') do
      delete :destroy, :id => expression_has_expressions(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy expression_has_expression" do
    login_as :user1
    assert_no_difference('ExpressionHasExpression.count') do
      delete :destroy, :id => expression_has_expressions(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy expression_has_expression" do
    login_as :librarian1
    assert_difference('ExpressionHasExpression.count', -1) do
      delete :destroy, :id => expression_has_expressions(:one).id
    end

    assert_redirected_to expression_has_expressions_path
  end
end
