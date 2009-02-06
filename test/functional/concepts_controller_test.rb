require 'test_helper'

class ConceptsControllerTest < ActionController::TestCase
  fixtures :concepts

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:concepts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create concept" do
    assert_difference('Concept.count') do
      post :create, :concept => { }
    end

    assert_redirected_to concept_path(assigns(:concept))
  end

  test "should show concept" do
    get :show, :id => concepts(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => concepts(:one).id
    assert_response :success
  end

  test "should update concept" do
    put :update, :id => concepts(:one).id, :concept => { }
    assert_redirected_to concept_path(assigns(:concept))
  end

  test "should destroy concept" do
    assert_difference('Concept.count', -1) do
      delete :destroy, :id => concepts(:one).id
    end

    assert_redirected_to concepts_path
  end
end
