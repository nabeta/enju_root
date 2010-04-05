require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  setup :activate_authlogic

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "admin should get new" do
    UserSession.create users(:admin)
    get :new
    assert_response :success
  end

  test "admin should create resource" do
    UserSession.create users(:admin)
    assert_difference('Resource.count') do
      post :create, :resource => {:iss_token => 'test'}
    end

    assert_redirected_to resource_path(assigns(:resource))
  end

  test "guest should show resource" do
    get :show, :id => resources(:resource_00001).to_param
    assert_response :success
  end

  test "admin should get edit" do
    UserSession.create users(:admin)
    get :edit, :id => resources(:resource_00001).to_param
    assert_response :success
  end

  test "admin should update resource" do
    UserSession.create users(:admin)
    put :update, :id => resources(:resource_00001).to_param, :resource => { }
    assert_redirected_to resource_path(assigns(:resource))
  end

  test "admin should not destroy resource" do
    UserSession.create users(:admin)
    assert_no_difference('Resource.count') do
      delete :destroy, :id => resources(:resource_00001).to_param
    end
    assert assigns(:resource).deleted_at

    assert_redirected_to resources_path
  end
end
