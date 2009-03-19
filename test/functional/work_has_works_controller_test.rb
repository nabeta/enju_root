require 'test_helper'

class WorkHasWorksControllerTest < ActionController::TestCase
  fixtures :work_has_works, :works, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_has_works)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
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

  test "guest should not create work_has_work" do
    assert_no_difference('WorkHasWork.count') do
      post :create, :work_has_work => {:from_work_id => 1, :to_work_id => 2}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create work_has_work" do
    login_as :user1
    assert_no_difference('WorkHasWork.count') do
      post :create, :work_has_work => {:from_work_id => 1, :to_work_id => 2}
    end

    assert_response :forbidden
  end

  test "librarian should create work_has_work" do
    login_as :librarian1
    assert_difference('WorkHasWork.count') do
      post :create, :work_has_work => {:from_work_id => 1, :to_work_id => 2}
    end

    assert_redirected_to work_has_work_path(assigns(:work_has_work))
  end

  test "should show work_has_work" do
    get :show, :id => work_has_works(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => work_has_works(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => work_has_works(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => work_has_works(:one).id
    assert_response :success
  end

  test "guest should not update work_has_work" do
    put :update, :id => work_has_works(:one).id, :work_has_work => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update work_has_work" do
    login_as :user1
    put :update, :id => work_has_works(:one).id, :work_has_work => { }
    assert_response :forbidden
  end

  test "librarian should update work_has_work" do
    login_as :librarian1
    put :update, :id => work_has_works(:one).id, :work_has_work => { }
    assert_redirected_to work_has_work_path(assigns(:work_has_work))
  end

  test "guest should not destroy work_has_work" do
    assert_no_difference('WorkHasWork.count') do
      delete :destroy, :id => work_has_works(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy work_has_work" do
    login_as :user1
    assert_no_difference('WorkHasWork.count') do
      delete :destroy, :id => work_has_works(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy work_has_work" do
    login_as :librarian1
    assert_difference('WorkHasWork.count', -1) do
      delete :destroy, :id => work_has_works(:one).id
    end

    assert_redirected_to work_has_works_path
  end
end
