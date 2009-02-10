require 'test_helper'

class ConceptsControllerTest < ActionController::TestCase
  fixtures :concepts, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:concepts)
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

  test "guest should not create concept" do
    assert_no_difference('Concept.count') do
      post :create, :concept => { }
    end

    assert_redirected_to new_session_url
  end

  test "user should not create concept" do
    login_as :user1
    assert_no_difference('Concept.count') do
      post :create, :concept => { }
    end

    assert_response :forbidden
  end

  test "librarian should create concept" do
    login_as :librarian1
    assert_difference('Concept.count') do
      post :create, :concept => {:term => 'hoge'}
    end

    assert_redirected_to concept_path(assigns(:concept))
  end

  test "guest should show concept" do
    get :show, :id => concepts(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => concepts(:one).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  test "user should not get edit" do
    login_as :user1
    get :edit, :id => concepts(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => concepts(:one).id
    assert_response :success
  end

  test "guest should not update concept" do
    put :update, :id => concepts(:one).id, :concept => { }
    assert_redirected_to new_session_url
  end

  test "user should not update concept" do
    login_as :user1
    put :update, :id => concepts(:one).id, :concept => { }
    assert_response :forbidden
  end

  test "librarian should update concept" do
    login_as :librarian1
    put :update, :id => concepts(:one).id, :concept => { }
    assert_redirected_to concept_path(assigns(:concept))
  end

  test "guest should not destroy concept" do
    assert_no_difference('Concept.count') do
      delete :destroy, :id => concepts(:one).id
    end

    assert_redirected_to new_session_url
  end

  test "user should not destroy concept" do
    login_as :user1
    assert_no_difference('Concept.count') do
      delete :destroy, :id => concepts(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy concept" do
    login_as :librarian1
    assert_difference('Concept.count', -1) do
      delete :destroy, :id => concepts(:one).id
    end

    assert_redirected_to concepts_path
  end
end
