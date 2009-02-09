require 'test_helper'

class CorporateBodiesControllerTest < ActionController::TestCase
  fixtures :corporate_bodies, :users

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corporate_bodies)
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

  test "guest should not create corporate_body" do
    assert_no_difference('CorporateBody.count') do
      post :create, :corporate_body => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create corporate_body" do
    login_as :user1
    assert_no_difference('CorporateBody.count') do
      post :create, :corporate_body => { }
    end

    assert_response :forbidden
  end

  test "librarian should create corporate_body" do
    login_as :librarian1
    assert_difference('CorporateBody.count') do
      post :create, :corporate_body => { }
    end

    assert_redirected_to corporate_body_path(assigns(:corporate_body))
  end

  test "guest should show corporate_body" do
    get :show, :id => corporate_bodies(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => corporate_bodies(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => corporate_bodies(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => corporate_bodies(:one).id
    assert_response :success
  end

  test "guest should not update corporate_body" do
    put :update, :id => corporate_bodies(:one).id, :corporate_body => { }
    assert_redirected_to new_session_url
  end

  test "user should not update corporate_body" do
    login_as :user1
    put :update, :id => corporate_bodies(:one).id, :corporate_body => { }
    assert_response :forbidden
  end

  test "librarian should update corporate_body" do
    login_as :librarian1
    put :update, :id => corporate_bodies(:one).id, :corporate_body => { }
    assert_redirected_to corporate_body_path(assigns(:corporate_body))
  end

  test "guest should not destroy corporate_body" do
    assert_no_difference('CorporateBody.count') do
      delete :destroy, :id => corporate_bodies(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy corporate_body" do
    login_as :user1
    assert_no_difference('CorporateBody.count') do
      delete :destroy, :id => corporate_bodies(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy corporate_body" do
    login_as :librarian1
    assert_difference('CorporateBody.count', -1) do
      delete :destroy, :id => corporate_bodies(:one).id
    end

    assert_redirected_to corporate_bodies_path
  end
end
