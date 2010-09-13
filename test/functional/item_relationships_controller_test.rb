require 'test_helper'

class ItemRelationshipsControllerTest < ActionController::TestCase
    fixtures :item_relationships, :items, :users, :item_relationship_types

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_relationships)
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

  test "guest should not create item_relationship" do
    assert_no_difference('ItemRelationship.count') do
      post :create, :item_relationship => {:parent_id => 1, :child_id => 2, :item_relationship_type_id => 1}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create item_relationship" do
    sign_in users(:user1)
    assert_no_difference('ItemRelationship.count') do
      post :create, :item_relationship => {:parent_id => 1, :child_id => 2, :item_relationship_type_id => 1}
    end

    assert_response :forbidden
  end

  test "librarian should create item_relationship" do
    sign_in users(:librarian1)
    assert_difference('ItemRelationship.count') do
      post :create, :item_relationship => {:parent_id => 1, :child_id => 2, :item_relationship_type_id => 1}
    end

    assert_redirected_to item_relationship_path(assigns(:item_relationship))
  end

  test "should show item_relationship" do
    get :show, :id => item_relationships(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => item_relationships(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => item_relationships(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => item_relationships(:one).id
    assert_response :success
  end

  test "guest should not update item_relationship" do
    put :update, :id => item_relationships(:one).id, :item_relationship => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update item_relationship" do
    sign_in users(:user1)
    put :update, :id => item_relationships(:one).id, :item_relationship => { }
    assert_response :forbidden
  end

  test "librarian should update item_relationship" do
    sign_in users(:librarian1)
    put :update, :id => item_relationships(:one).id, :item_relationship => { }
    assert_redirected_to item_relationship_path(assigns(:item_relationship))
  end

  test "guest should not destroy item_relationship" do
    assert_no_difference('ItemRelationship.count') do
      delete :destroy, :id => item_relationships(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy item_relationship" do
    sign_in users(:user1)
    assert_no_difference('ItemRelationship.count') do
      delete :destroy, :id => item_relationships(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy item_relationship" do
    sign_in users(:librarian1)
    assert_difference('ItemRelationship.count', -1) do
      delete :destroy, :id => item_relationships(:one).id
    end

    assert_redirected_to item_relationships_path
  end
end
