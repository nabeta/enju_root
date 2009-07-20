require 'test_helper'

class ContentTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:content_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create content_type" do
    assert_difference('ContentType.count') do
      post :create, :content_type => { }
    end

    assert_redirected_to content_type_path(assigns(:content_type))
  end

  test "should show content_type" do
    get :show, :id => content_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => content_types(:one).to_param
    assert_response :success
  end

  test "should update content_type" do
    put :update, :id => content_types(:one).to_param, :content_type => { }
    assert_redirected_to content_type_path(assigns(:content_type))
  end

  test "should destroy content_type" do
    assert_difference('ContentType.count', -1) do
      delete :destroy, :id => content_types(:one).to_param
    end

    assert_redirected_to content_types_path
  end
end
