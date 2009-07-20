require 'test_helper'

class MediumOfPerformancesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:medium_of_performances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medium_of_performance" do
    assert_difference('MediumOfPerformance.count') do
      post :create, :medium_of_performance => { }
    end

    assert_redirected_to medium_of_performance_path(assigns(:medium_of_performance))
  end

  test "should show medium_of_performance" do
    get :show, :id => medium_of_performances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => medium_of_performances(:one).to_param
    assert_response :success
  end

  test "should update medium_of_performance" do
    put :update, :id => medium_of_performances(:one).to_param, :medium_of_performance => { }
    assert_redirected_to medium_of_performance_path(assigns(:medium_of_performance))
  end

  test "should destroy medium_of_performance" do
    assert_difference('MediumOfPerformance.count', -1) do
      delete :destroy, :id => medium_of_performances(:one).to_param
    end

    assert_redirected_to medium_of_performances_path
  end
end
