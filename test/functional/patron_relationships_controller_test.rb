require 'test_helper'

class PatronRelationshipsControllerTest < ActionController::TestCase
    fixtures :patron_relationships, :patrons, :users, :patron_relationship_types

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_relationships)
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

  test "guest should not create patron_relationship" do
    assert_no_difference('PatronRelationship.count') do
      post :create, :patron_relationship => {:parent_id => 1, :child_id => 2, :patron_relationship_type_id => 1}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create patron_relationship" do
    sign_in users(:user1)
    assert_no_difference('PatronRelationship.count') do
      post :create, :patron_relationship => {:parent_id => 1, :child_id => 2, :patron_relationship_type_id => 1}
    end

    assert_response :forbidden
  end

  test "librarian should create patron_relationship" do
    sign_in users(:librarian1)
    assert_difference('PatronRelationship.count') do
      post :create, :patron_relationship => {:parent_id => 1, :child_id => 2, :patron_relationship_type_id => 1}
    end

    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "should show patron_relationship" do
    get :show, :id => patron_relationships(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => patron_relationships(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => patron_relationships(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => patron_relationships(:one).id
    assert_response :success
  end

  test "guest should not update patron_relationship" do
    put :update, :id => patron_relationships(:one).id, :patron_relationship => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update patron_relationship" do
    sign_in users(:user1)
    put :update, :id => patron_relationships(:one).id, :patron_relationship => { }
    assert_response :forbidden
  end

  test "librarian should update patron_relationship" do
    sign_in users(:librarian1)
    put :update, :id => patron_relationships(:one).id, :patron_relationship => { }
    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "guest should not destroy patron_relationship" do
    assert_no_difference('PatronRelationship.count') do
      delete :destroy, :id => patron_relationships(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy patron_relationship" do
    sign_in users(:user1)
    assert_no_difference('PatronRelationship.count') do
      delete :destroy, :id => patron_relationships(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy patron_relationship" do
    sign_in users(:librarian1)
    assert_difference('PatronRelationship.count', -1) do
      delete :destroy, :id => patron_relationships(:one).id
    end

    assert_redirected_to patron_relationships_path
  end
end
