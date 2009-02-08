require 'test_helper'

class CorporateBodiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corporate_bodies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create corporate_body" do
    assert_difference('CorporateBody.count') do
      post :create, :corporate_body => { }
    end

    assert_redirected_to corporate_body_path(assigns(:corporate_body))
  end

  test "should show corporate_body" do
    get :show, :id => corporate_bodies(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => corporate_bodies(:one).id
    assert_response :success
  end

  test "should update corporate_body" do
    put :update, :id => corporate_bodies(:one).id, :corporate_body => { }
    assert_redirected_to corporate_body_path(assigns(:corporate_body))
  end

  test "should destroy corporate_body" do
    assert_difference('CorporateBody.count', -1) do
      delete :destroy, :id => corporate_bodies(:one).id
    end

    assert_redirected_to corporate_bodies_path
  end
end
