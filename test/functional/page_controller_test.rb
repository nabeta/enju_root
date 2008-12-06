require File.dirname(__FILE__) + '/../test_helper'
require 'page_controller'

class PageControllerTest < ActionController::TestCase
  fixtures :users

  # Replace this with your real tests.
  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_user_should_get_user_show
    login_as :user1
    get :index
    assert_response :redirect
    assert_redirected_to user_url(users(:user1).login)
  end

  def test_guest_should_get_advanced_search
    get :advanced_search
    assert_response :success
    assert assigns(:libraries)
  end

  def test_guest_should_get_opensearch
    get :opensearch
    assert_response :success
  end

  def test_guest_should_get_about
    get :about
    assert_response :success
  end

  def test_guest_should_not_get_import
    get :import
    assert_response :forbidden
  end

  def test_guest_should_not_get_import
    login_as :librarian1
    get :import
    assert_response :success
  end

  def test_guest_should_not_get_message
    get :message
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_get_message
    login_as :user1
    get :message
    assert_response :redirect
    assert_redirected_to inbox_user_messages_url(users(:user1).login)
  end

  def test_guest_should_not_get_acquisition
    get :acquisition
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_acquisition
    login_as :user1
    get :acquisition
    assert_response :forbidden
  end

  def test_librarian_should_get_acquisition
    login_as :librarian1
    get :acquisition
    assert_response :success
  end

  def test_guest_should_not_get_configuration
    get :confdiguration
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_configuration
    login_as :user1
    get :configuration
    assert_response :forbidden
  end

  def test_librarian_should_get_configuration
    login_as :librarian1
    get :configuration
    assert_response :success
  end

  def test_guest_should_not_get_patron
    get :patron
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_patron
    login_as :user1
    get :patron
    assert_response :forbidden
  end

  def test_librarian_should_get_patron
    login_as :librarian1
    get :patron
    assert_response :success
  end

  def test_guest_should_not_get_circulation
    get :patron
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_circulation
    login_as :user1
    get :patron
    assert_response :forbidden
  end

  def test_librarian_should_get_circulation
    login_as :librarian1
    get :patron
    assert_response :success
  end

  def test_guest_should_not_get_management
    get :management
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_management
    login_as :user1
    get :management
    assert_response :forbidden
  end

  def test_librarian_should_get_management
    login_as :librarian1
    get :management
    assert_response :success
  end

end
