require 'test_helper'

class ExpressionRelationshipsControllerTest < ActionController::TestCase
    fixtures :expression_relationships, :expressions, :users, :expression_relationship_types

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_relationships)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create expression_relationship" do
    assert_no_difference('ExpressionRelationship.count') do
      post :create, :expression_relationship => {:parent_id => 1, :child_id => 2, :expression_relationship_type_id => 1}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create expression_relationship" do
    sign_in users(:user1)
    assert_no_difference('ExpressionRelationship.count') do
      post :create, :expression_relationship => {:parent_id => 1, :child_id => 2, :expression_relationship_type_id => 1}
    end

    assert_response :forbidden
  end

  test "librarian should create expression_relationship" do
    sign_in users(:librarian1)
    assert_difference('ExpressionRelationship.count') do
      post :create, :expression_relationship => {:parent_id => 1, :child_id => 2, :expression_relationship_type_id => 1}
    end

    assert_redirected_to expression_relationship_path(assigns(:expression_relationship))
  end

  test "should show expression_relationship" do
    get :show, :id => expression_relationships(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => expression_relationships(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => expression_relationships(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => expression_relationships(:one).id
    assert_response :success
  end

  test "guest should not update expression_relationship" do
    put :update, :id => expression_relationships(:one).id, :expression_relationship => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update expression_relationship" do
    sign_in users(:user1)
    put :update, :id => expression_relationships(:one).id, :expression_relationship => { }
    assert_response :forbidden
  end

  test "librarian should update expression_relationship" do
    sign_in users(:librarian1)
    put :update, :id => expression_relationships(:one).id, :expression_relationship => { }
    assert_redirected_to expression_relationship_path(assigns(:expression_relationship))
  end

  test "guest should not destroy expression_relationship" do
    assert_no_difference('ExpressionRelationship.count') do
      delete :destroy, :id => expression_relationships(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy expression_relationship" do
    sign_in users(:user1)
    assert_no_difference('ExpressionRelationship.count') do
      delete :destroy, :id => expression_relationships(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy expression_relationship" do
    sign_in users(:librarian1)
    assert_difference('ExpressionRelationship.count', -1) do
      delete :destroy, :id => expression_relationships(:one).id
    end

    assert_redirected_to expression_relationships_path
  end
end
