require 'test_helper'

class PageControllerTest < ActionController::TestCase
    fixtures :users

  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_user_should_get_user_show
    sign_in users(:user1)
    get :index
    assert_response :redirect
    assert_redirected_to user_url(users(:user1).username)
  end

  def test_guest_should_get_advanced_search
    get :advanced_search
    assert_response :success
    assert assigns(:libraries)
  end

  def test_guest_should_get_about
    get :about
    assert_response :success
  end

  def test_guest_should_get_add_on
    get :add_on
    assert_response :success
  end

  def test_guest_should_not_get_import
    get :import
    assert_response :forbidden
  end

  def test_guest_should_not_get_import
    sign_in users(:librarian1)
    get :import
    assert_response :success
  end

  def test_guest_should_not_get_message
    get :message
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_message
    sign_in users(:user1)
    get :message
    assert_response :redirect
    assert_redirected_to inbox_user_messages_url(users(:user1).username)
  end

  def test_guest_should_not_get_acquisition
    get :acquisition
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_acquisition
    sign_in users(:user1)
    get :acquisition
    assert_response :forbidden
  end

  def test_librarian_should_get_acquisition
    sign_in users(:librarian1)
    get :acquisition
    assert_response :success
  end

  def test_guest_should_not_get_configuration
    get :confdiguration
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_configuration
    sign_in users(:user1)
    get :configuration
    assert_response :forbidden
  end

  def test_librarian_should_get_configuration
    sign_in users(:librarian1)
    get :configuration
    assert_response :success
  end

  def test_guest_should_not_get_patron
    get :patron
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_patron
    sign_in users(:user1)
    get :patron
    assert_response :forbidden
  end

  def test_librarian_should_get_patron
    sign_in users(:librarian1)
    get :patron
    assert_response :success
  end

  def test_guest_should_not_get_circulation
    get :patron
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_circulation
    sign_in users(:user1)
    get :patron
    assert_response :forbidden
  end

  def test_librarian_should_get_circulation
    sign_in users(:librarian1)
    get :patron
    assert_response :success
  end

  def test_guest_should_not_get_management
    get :management
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_management
    sign_in users(:user1)
    get :management
    assert_response :forbidden
  end

  def test_librarian_should_get_management
    sign_in users(:librarian1)
    get :management
    assert_response :success
  end

  test "guest_should_get_opensearch" do
    get :opensearch
    assert_response :success
  end

  test "guest_should_get_msie_acceralator" do
    get :msie_acceralator
    assert_response :success
  end

end
