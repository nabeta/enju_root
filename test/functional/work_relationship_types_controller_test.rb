require 'test_helper'

class WorkRelationshipTypesControllerTest < ActionController::TestCase
  fixtures :work_relationship_types

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_relationship_type" do
    assert_difference('WorkRelationshipType.count') do
      post :create, :work_relationship_type => { }
    end

    assert_redirected_to work_relationship_type_path(assigns(:work_relationship_type))
  end

  test "should show work_relationship_type" do
    get :show, :id => work_relationship_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => work_relationship_types(:one).id
    assert_response :success
  end

  test "should update work_relationship_type" do
    put :update, :id => work_relationship_types(:one).id, :work_relationship_type => { }
    assert_redirected_to work_relationship_type_path(assigns(:work_relationship_type))
  end

  test "should destroy work_relationship_type" do
    assert_difference('WorkRelationshipType.count', -1) do
      delete :destroy, :id => work_relationship_types(:one).id
    end

    assert_redirected_to work_relationship_types_path
  end
end
