require 'test_helper'

class UseRestrictionsControllerTest < ActionController::TestCase
  fixtures :use_restrictions, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:use_restrictions)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:use_restrictions)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:use_restrictions)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert_not_nil assigns(:use_restrictions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
  end

  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_not_get_new
    login_as :librarian1
    get :new
    assert_response :forbidden
  end

  def test_admin_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_use_restriction
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_use_restriction
    login_as :user1
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_use_restriction
    login_as :librarian1
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :forbidden
  end

  def test_admin_should_not_create_use_restriction_without_name
    login_as :admin
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :success
  end

  def test_admin_should_create_use_restriction
    login_as :admin
    assert_difference('UseRestriction.count') do
      post :create, :use_restriction => {:name => 'test'}
    end

    assert_redirected_to use_restriction_url(assigns(:use_restriction))
  end

  def test_guest_should_not_show_use_restriction
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_use_restriction
    login_as :user1
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_use_restriction
    login_as :librarian1
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_admin_should_not_show_use_restriction
    login_as :admin
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_use_restriction
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_use_restriction
    login_as :user1
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_use_restriction
    login_as :librarian1
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :forbidden
  end

  def test_admin_should_not_update_use_restriction_without_name
    login_as :admin
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => {:name => ""}
    assert_response :success
  end

  def test_admin_should_update_use_restriction
    login_as :admin
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_redirected_to use_restriction_url(assigns(:use_restriction))
  end

  def test_guest_should_not_destroy_use_restriction
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_use_restriction
    login_as :user1
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_use_restriction
    login_as :librarian1
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_destroy_use_restriction
    login_as :admin
    assert_difference('UseRestriction.count', -1) do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_redirected_to use_restrictions_url
  end
end
