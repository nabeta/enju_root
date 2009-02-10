require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  fixtures :places, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:places)
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

  test "guest should not create place" do
    assert_no_difference('Place.count') do
      post :create, :place => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create place" do
    login_as :user1
    assert_no_difference('Place.count') do
      post :create, :place => { }
    end

    assert_response :forbidden
  end

  test "librarian should create place" do
    login_as :librarian1
    assert_difference('Place.count') do
      post :create, :place => {:term => 'hoge'}
    end

    assert_redirected_to place_path(assigns(:place))
  end

  test "guest should show place" do
    get :show, :id => places(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => places(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => places(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => places(:one).id
    assert_response :success
  end

  test "guest should not update place" do
    put :update, :id => places(:one).id, :place => { }
    assert_redirected_to new_session_url
  end

  test "user should not update place" do
    login_as :user1
    put :update, :id => places(:one).id, :place => { }
    assert_response :forbidden
  end

  test "librarian should update place" do
    login_as :librarian1
    put :update, :id => places(:one).id, :place => { }
    assert_redirected_to place_path(assigns(:place))
  end

  test "guest should not destroy place" do
    assert_no_difference('Place.count') do
      delete :destroy, :id => places(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy place" do
    login_as :user1
    assert_no_difference('Place.count') do
      delete :destroy, :id => places(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy place" do
    login_as :librarian1
    assert_difference('Place.count', -1) do
      delete :destroy, :id => places(:one).id
    end

    assert_redirected_to places_path
  end
end
