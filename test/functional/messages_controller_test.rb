require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :users, :messages, :patrons, :patron_types

  def test_should_get_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :redirect
    assert_redirected_to inbox_user_messages_path
  end
  
  def test_should_get_inbox
    UserSession.create users(:user1)
    get :inbox, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_should_get_outbox
    UserSession.create users(:user1)
    get :outbox, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_should_get_trashbin
    UserSession.create users(:user1)
    get :inbox, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_should_get_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_should_route_messages_of_user
    options = { :controller => 'messages',
                :action => 'inbox',
                :user_id => '3' }
    assert_routing('users/3/messages/inbox', options)
  end
  
  def test_should_get_message
    UserSession.create users(:user1)
    get :show, :user_id => users(:user1).login, :id => messages(:user2_to_user1_1)
    assert_response :success
  end
  
  def test_should_protect_message
    UserSession.create users(:user1)
    get :show, :user_id => users(:user1).login, :id => messages(:user2_to_catie_1)
    assert_response :forbidden
  end
  
  def test_should_create_message
    message_count = Message.count
    UserSession.create users(:user1)
    post :create, :user_id => users(:user1).login, :message => {:recipient => 'user2', :subject => "hi", :body => "Abby, how was school today?"}
    assert_response :redirect
    assert_redirected_to outbox_user_messages_path
    assert_equal message_count + 1, Message.count
  end
  
  def test_should_delete_received_message
    message_pre_delete_state = Message.find(messages(:user2_to_user1_1))
    UserSession.create users(:user1)
    delete :destroy, :user_id => users(:user1).login, :id => messages(:user2_to_user1_1)
    assert_response :redirect
    message_post_delete_state = Message.find(messages(:user2_to_user1_1))
    assert_not_equal message_pre_delete_state.receiver_deleted, message_post_delete_state.receiver_deleted
  end
  
  def test_should_delete_sent_message
    message_pre_delete_state = Message.find(messages(:user1_to_user2_1))
    UserSession.create users(:user1)
    delete :destroy, :user_id => users(:user1).login, :id => messages(:user1_to_user2_1)
    assert_response :redirect
    message_post_delete_state = Message.find(messages(:user1_to_user2_1))
    assert_not_equal message_pre_delete_state.sender_deleted, message_post_delete_state.sender_deleted
  end

  def test_should_not_delete_message
    message_pre_delete_state = Message.find(messages(:user2_to_user1_1))
    UserSession.create users(:user1)
    delete :destroy, :user_id => users(:user1).login, :id => messages(:user2_to_catie_1)
    assert_response :forbidden
    message_post_delete_state = Message.find(messages(:user2_to_user1_1))
    assert_equal message_pre_delete_state.receiver_deleted, message_post_delete_state.receiver_deleted
  end
  
  def test_should_reply_to_message
    UserSession.create users(:user1)
    get :reply, :user_id => users(:user1).login, :id => messages(:user2_to_user1_1)
    assert_response :success
  end
  
  def test_should_not_reply_to_message
    UserSession.create users(:user1)
    get :reply, :user_id => users(:user1).login, :id => messages(:user2_to_catie_1)
    assert_response :forbidden
  end
end
