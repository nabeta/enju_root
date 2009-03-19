require 'test_helper'

class MessageQueuesControllerTest < ActionController::TestCase
  fixtures :message_queues, :users, :user_groups, :patrons, :message_templates

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:message_queues)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
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

  def test_guest_should_not_create_message_queue
    assert_no_difference('MessageQueue.count') do
      post :create, :message_queue => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_message_queue
    login_as :user1
    assert_no_difference('MessageQueue.count') do
      post :create, :message_queue => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_message_queue
    login_as :librarian1
    assert_no_difference('MessageQueue.count') do
      post :create, :message_queue => {:sender_id => 1, :receiver_id => 2, :message_template_id => 1}
    end

    #assert_redirected_to message_queue_path(assigns(:message_queue))
    assert_response :forbidden
  end

  def test_guest_should_not_show_message_queue
    get :show, :id => message_queues(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_message_queue
    login_as :user1
    get :show, :id => message_queues(:one).id
    assert_response :forbidden
  end

  def test_librarian_should_show_message_queue
    login_as :librarian1
    get :show, :id => message_queues(:one).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => message_queues(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => message_queues(:one).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => message_queues(:one).id
    assert_response :success
  end

  def test_guest_should_not_update_message_queue
    put :update, :id => message_queues(:one).id, :message_queue => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_message_queue
    login_as :user1
    put :update, :id => message_queues(:one).id, :message_queue => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_message_queue
    login_as :librarian1
    put :update, :id => message_queues(:one).id, :message_queue => { }
    assert_redirected_to message_queue_path(assigns(:message_queue))
  end

  def test_guest_should_not_destroy_message_queue
    assert_no_difference('MessageQueue.count', -1) do
      delete :destroy, :id => message_queues(:one).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_message_queue
    login_as :user1
    assert_no_difference('MessageQueue.count', -1) do
      delete :destroy, :id => message_queues(:one).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_message_queue
    login_as :librarian1
    assert_difference('MessageQueue.count', -1) do
      delete :destroy, :id => message_queues(:one).id
    end

    assert_redirected_to message_queues_path
  end
end
