require 'test_helper'

class ExtentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:extents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create extent" do
    assert_difference('Extent.count') do
      post :create, :extent => { }
    end

    assert_redirected_to extent_path(assigns(:extent))
  end

  test "should show extent" do
    get :show, :id => extents(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => extents(:one).to_param
    assert_response :success
  end

  test "should update extent" do
    put :update, :id => extents(:one).to_param, :extent => { }
    assert_redirected_to extent_path(assigns(:extent))
  end

  test "should destroy extent" do
    assert_difference('Extent.count', -1) do
      delete :destroy, :id => extents(:one).to_param
    end

    assert_redirected_to extents_path
  end
end
