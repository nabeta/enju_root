require 'test_helper'

class UserHasShelvesControllerTest < ActionController::TestCase
  fixtures :user_has_shelves, :users

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get index" do
    sign_in users(:user1)
    get :index
    assert_response :success
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

  test "librarian should not get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  test "admin should not get new" do
    sign_in users(:admin)
    get :new
    assert_response :forbidden
  end

  test "guest should not create user_has_shelf" do
    assert_no_difference('UserHasShelf.count') do
      post :create, :user_has_shelf => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should create my user_has_shelf" do
    sign_in users(:user1)
    assert_difference('UserHasShelf.count') do
      post :create, :user_has_shelf => {:user_id => 3, :shelf_id => 3}
    end

    assert_redirected_to user_has_shelf_path(assigns(:user_has_shelf))
  end

  test "user should not create other user_has_shelf" do
    sign_in users(:user1)
    assert_difference('UserHasShelf.count') do
      post :create, :user_has_shelf => {:user_id => 1, :shelf_id => 1}
    end

    assert_redirected_to user_has_shelf_path(assigns(:user_has_shelf))
  end

  test "librarian should create other user_has_shelf" do
    sign_in users(:librarian1)
    assert_difference('UserHasShelf.count') do
      post :create, :user_has_shelf => {:user_id => 1, :shelf_id => 1}
    end

    assert_redirected_to user_has_shelf_path(assigns(:user_has_shelf))
  end

  test "guest should not show user_has_shelf" do
    get :show, :id => user_has_shelves(:one).to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should show my user_has_shelf" do
    sign_in users(:user1)
    get :show, :id => user_has_shelves(:three).to_param
    assert_response :success
    assert assigns(:user_has_shelf)
  end

  test "user should not show other user_has_shelf" do
    sign_in users(:user1)
    get :show, :id => user_has_shelves(:one).to_param
    assert_response :forbidden
  end

  test "librarian should show other user_has_shelf" do
    sign_in users(:librarian1)
    get :show, :id => user_has_shelves(:one).to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => user_has_shelves(:one).to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get my edit" do
    sign_in users(:user1)
    get :edit, :id => user_has_shelves(:three).to_param
    assert_response :success
  end

  test "user should not get other edit" do
    sign_in users(:user1)
    get :edit, :id => user_has_shelves(:one).to_param
    assert_response :forbidden
  end

  test "librarian should get other edit" do
    sign_in users(:librarian1)
    get :edit, :id => user_has_shelves(:one).to_param
    assert_response :success
  end

  test "guest should not update user_has_shelf" do
    put :update, :id => user_has_shelves(:one).to_param, :user_has_shelf => { }
    assert_redirected_to new_user_session_url
  end

  test "user should update my user_has_shelf" do
    sign_in users(:user1)
    put :update, :id => user_has_shelves(:three).to_param, :user_has_shelf => { }
    assert_redirected_to user_has_shelf_path(assigns(:user_has_shelf))
  end

  test "user should not update other user_has_shelf" do
    sign_in users(:user1)
    put :update, :id => user_has_shelves(:one).to_param, :user_has_shelf => { }
    assert_response :forbidden
  end

  test "librarian should update other user_has_shelf" do
    sign_in users(:librarian1)
    put :update, :id => user_has_shelves(:one).to_param, :user_has_shelf => { }
    assert_redirected_to user_has_shelf_path(assigns(:user_has_shelf))
  end

  test "guest should not destroy user_has_shelf" do
    assert_no_difference('UserHasShelf.count', -1) do
      delete :destroy, :id => user_has_shelves(:one).to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should destroy my user_has_shelf" do
    sign_in users(:user1)
    assert_difference('UserHasShelf.count', -1) do
      delete :destroy, :id => user_has_shelves(:three).to_param
    end

    assert_redirected_to user_has_shelves_path
  end

  test "user should not destroy other user_has_shelf" do
    sign_in users(:user1)
    assert_no_difference('UserHasShelf.count') do
      delete :destroy, :id => user_has_shelves(:one).to_param
    end

    assert_response :forbidden
  end

  test "librarian should destroy user_has_shelf" do
    sign_in users(:librarian1)
    assert_difference('UserHasShelf.count', -1) do
      delete :destroy, :id => user_has_shelves(:one).to_param
    end

    assert_redirected_to user_has_shelves_path
  end
end
