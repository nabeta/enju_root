require 'test_helper'

class FamiliesControllerTest < ActionController::TestCase
  fixtures :families, :users

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:families)
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

  test "guest should not create family" do
    assert_no_difference('Family.count') do
      post :create, :family => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create family" do
    login_as :user1
    assert_no_difference('Family.count') do
      post :create, :family => { }
    end

    assert_response :forbidden
  end

  test "librarian should create family" do
    login_as :librarian1
    assert_difference('Family.count') do
      post :create, :family => {:full_name => 'hoge'}
    end

    assert_redirected_to family_path(assigns(:family))
  end

  test "guest should show family" do
    get :show, :id => families(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => families(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => families(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => families(:one).id
    assert_response :success
  end

  test "guest should not update family" do
    put :update, :id => families(:one).id, :family => { }
    assert_redirected_to new_session_url
  end

  test "user should not update family" do
    login_as :user1
    put :update, :id => families(:one).id, :family => { }
    assert_response :forbidden
  end

  test "librarian should update family" do
    login_as :librarian1
    put :update, :id => families(:one).id, :family => { }
    assert_redirected_to family_path(assigns(:family))
  end

  test "guest should not destroy family" do
    assert_no_difference('Family.count') do
      delete :destroy, :id => families(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy family" do
    login_as :user1
    assert_no_difference('Family.count') do
      delete :destroy, :id => families(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy family" do
    login_as :librarian1
    assert_difference('Family.count', -1) do
      delete :destroy, :id => families(:one).id
    end

    assert_redirected_to families_path
  end
end
