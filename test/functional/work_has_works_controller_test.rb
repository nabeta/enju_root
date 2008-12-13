require 'test_helper'

class WorkHasWorksControllerTest < ActionController::TestCase
  fixtures :work_has_works

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_has_works)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_has_work" do
    assert_difference('WorkHasWork.count') do
      post :create, :work_has_work => { }
    end

    assert_redirected_to work_has_work_path(assigns(:work_has_work))
  end

  test "should show work_has_work" do
    get :show, :id => work_has_works(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => work_has_works(:one).id
    assert_response :success
  end

  test "should update work_has_work" do
    put :update, :id => work_has_works(:one).id, :work_has_work => { }
    assert_redirected_to work_has_work_path(assigns(:work_has_work))
  end

  test "should destroy work_has_work" do
    assert_difference('WorkHasWork.count', -1) do
      delete :destroy, :id => work_has_works(:one).id
    end

    assert_redirected_to work_has_works_path
  end
end
