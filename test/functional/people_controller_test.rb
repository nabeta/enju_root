require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  fixtures :people, :users

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
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

  test "guest should not create person" do
    assert_no_difference('Person.count') do
      post :create, :person => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create person" do
    login_as :user1
    assert_no_difference('Person.count') do
      post :create, :person => { }
    end

    assert_response :forbidden
  end

  test "librarian should create person" do
    login_as :librarian1
    assert_difference('Person.count') do
      post :create, :person => {:full_name => 'hoge'}
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "guest should show person" do
    get :show, :id => people(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => people(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => people(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => people(:one).id
    assert_response :success
  end

  test "guest should not update person" do
    put :update, :id => people(:one).id, :person => { }
    assert_redirected_to new_session_url
  end

  test "user should not update person" do
    login_as :user1
    put :update, :id => people(:one).id, :person => { }
    assert_response :forbidden
  end

  test "librarian should update person" do
    login_as :librarian1
    put :update, :id => people(:one).id, :person => { }
    assert_redirected_to person_path(assigns(:person))
  end

  test "guest should not destroy person" do
    assert_no_difference('Person.count') do
      delete :destroy, :id => people(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy person" do
    login_as :user1
    assert_no_difference('Person.count') do
      delete :destroy, :id => people(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy person" do
    login_as :librarian1
    assert_difference('Person.count', -1) do
      delete :destroy, :id => people(:one).id
    end

    assert_redirected_to people_path
  end
end
