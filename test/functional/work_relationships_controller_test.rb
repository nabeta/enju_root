require 'test_helper'

class WorkRelationshipsControllerTest < ActionController::TestCase
  fixtures :work_relationships, :works, :users, :work_relationship_types

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_relationships)
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

  test "guest should not create work_relationship" do
    assert_no_difference('WorkRelationship.count') do
      post :create, :work_relationship => {:parent_id => 1, :child_id => 2, :work_relationship_type_id => 1}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create work_relationship" do
    sign_in users(:user1)
    assert_no_difference('WorkRelationship.count') do
      post :create, :work_relationship => {:parent_id => 1, :child_id => 2, :work_relationship_type_id => 1}
    end

    assert_response :forbidden
  end

  test "librarian should create work_relationship" do
    sign_in users(:librarian1)
    assert_difference('WorkRelationship.count') do
      post :create, :work_relationship => {:parent_id => 1, :child_id => 2, :work_relationship_type_id => 1}
    end

    assert_redirected_to work_relationship_path(assigns(:work_relationship))
  end

  test "should show work_relationship" do
    get :show, :id => work_relationships(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => work_relationships(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => work_relationships(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => work_relationships(:one).id
    assert_response :success
  end

  test "guest should not update work_relationship" do
    put :update, :id => work_relationships(:one).id, :work_relationship => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update work_relationship" do
    sign_in users(:user1)
    put :update, :id => work_relationships(:one).id, :work_relationship => { }
    assert_response :forbidden
  end

  test "librarian should update work_relationship" do
    sign_in users(:librarian1)
    put :update, :id => work_relationships(:one).id, :work_relationship => { }
    assert_redirected_to work_relationship_path(assigns(:work_relationship))
  end

  test "guest should not destroy work_relationship" do
    assert_no_difference('WorkRelationship.count') do
      delete :destroy, :id => work_relationships(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy work_relationship" do
    sign_in users(:user1)
    assert_no_difference('WorkRelationship.count') do
      delete :destroy, :id => work_relationships(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy work_relationship" do
    sign_in users(:librarian1)
    assert_difference('WorkRelationship.count', -1) do
      delete :destroy, :id => work_relationships(:one).id
    end

    assert_redirected_to work_relationships_path
  end
end
