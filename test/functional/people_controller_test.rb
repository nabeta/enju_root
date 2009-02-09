require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  fixtures :people

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, :person => { }
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "guest should show person" do
    get :show, :id => people(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => people(:one).id
    assert_response :success
  end

  test "should update person" do
    put :update, :id => people(:one).id, :person => { }
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, :id => people(:one).id
    end

    assert_redirected_to people_path
  end
end
