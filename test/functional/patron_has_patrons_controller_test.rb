require 'test_helper'

class PatronHasPatronsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :patron_has_patrons, :patrons, :users, :patron_relationship_types

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_has_patrons)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    UserSession.create users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create patron_has_patron" do
    assert_no_difference('PatronHasPatron.count') do
      post :create, :patron_has_patron => {:from_patron_id => 1, :to_patron_id => 2, :patron_relationship_type_id => 1}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create patron_has_patron" do
    UserSession.create users(:user1)
    assert_no_difference('PatronHasPatron.count') do
      post :create, :patron_has_patron => {:from_patron_id => 1, :to_patron_id => 2, :patron_relationship_type_id => 1}
    end

    assert_response :forbidden
  end

  test "librarian should create patron_has_patron" do
    UserSession.create users(:librarian1)
    assert_difference('PatronHasPatron.count') do
      post :create, :patron_has_patron => {:from_patron_id => 1, :to_patron_id => 2, :patron_relationship_type_id => 1}
    end

    assert_redirected_to patron_has_patron_path(assigns(:patron_has_patron))
  end

  test "should show patron_has_patron" do
    get :show, :id => patron_has_patrons(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => patron_has_patrons(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    UserSession.create users(:user1)
    get :edit, :id => patron_has_patrons(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    UserSession.create users(:librarian1)
    get :edit, :id => patron_has_patrons(:one).id
    assert_response :success
  end

  test "guest should not update patron_has_patron" do
    put :update, :id => patron_has_patrons(:one).id, :patron_has_patron => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update patron_has_patron" do
    UserSession.create users(:user1)
    put :update, :id => patron_has_patrons(:one).id, :patron_has_patron => { }
    assert_response :forbidden
  end

  test "librarian should update patron_has_patron" do
    UserSession.create users(:librarian1)
    put :update, :id => patron_has_patrons(:one).id, :patron_has_patron => { }
    assert_redirected_to patron_has_patron_path(assigns(:patron_has_patron))
  end

  test "guest should not destroy patron_has_patron" do
    assert_no_difference('PatronHasPatron.count') do
      delete :destroy, :id => patron_has_patrons(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy patron_has_patron" do
    UserSession.create users(:user1)
    assert_no_difference('PatronHasPatron.count') do
      delete :destroy, :id => patron_has_patrons(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy patron_has_patron" do
    UserSession.create users(:librarian1)
    assert_difference('PatronHasPatron.count', -1) do
      delete :destroy, :id => patron_has_patrons(:one).id
    end

    assert_redirected_to patron_has_patrons_path
  end
end
