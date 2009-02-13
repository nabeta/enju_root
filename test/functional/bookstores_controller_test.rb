require 'test_helper'

class BookstoresControllerTest < ActionController::TestCase
  fixtures :bookstores, :users, :patrons, :patron_types, :roles, :languages,
    :libraries, :library_groups, :user_groups

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_nil assigns(:bookstores)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:bookstores)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:bookstores)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
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

  def test_admin_should_not_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_bookstore
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_bookstore
    login_as :user1
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_bookstore
    login_as :librarian1
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :forbidden
  end

  def test_admin_should_not_create_bookstore_without_name
    login_as :admin
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :success
  end

  def test_admin_should_not_create_bookstore
    login_as :admin
    assert_difference('Bookstore.count') do
      post :create, :bookstore => {:name => 'test'}
    end

    assert_redirected_to bookstore_url(assigns(:bookstore))
  end

  def test_guest_should_not_show_bookstore
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_bookstore
    login_as :user1
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_bookstore
    login_as :librarian1
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_bookstore
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_update_bookstore
    login_as :user1
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_bookstore
    login_as :librarian1
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :forbidden
  end

  def test_admin_should_not_update_bookstore_without_name
    login_as :admin
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => {:name => ""}
    assert_response :success
  end

  def test_admin_should_update_bookstore
    login_as :admin
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_redirected_to bookstore_url(assigns(:bookstore))
  end

  def test_guest_should_not_destroy_bookstore
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_bookstore
    login_as :user1
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_bookstore
    login_as :librarian1
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_destroy_bookstore
    login_as :admin
    assert_difference('Bookstore.count', -1) do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_redirected_to bookstores_url
  end
end
