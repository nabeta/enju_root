require File.dirname(__FILE__) + '/../test_helper'
require 'messages_controller'

# Re-raise errors caught by the controller.
class MessagesController; def rescue_action(e) raise e end; end

class MessagesControllerTest < Test::Unit::TestCase

  include AuthenticatedTestHelper

  fixtures :users, :messages

  def setup
    @controller = MessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as("sam")
    get :index
    assert_response :redirect
    assert_redirected_to inbox_messages_path
  end
  
  def test_should_get_inbox
    login_as("sam")
    get :inbox
    assert_response :success
  end
  
  def test_should_get_outbox
    login_as("sam")
    get :outbox
    assert_response :success
  end
  
  def test_should_get_trashbin
    login_as("sam")
    get :inbox
    assert_response :success
  end
  
  def test_should_get_new
    login_as("sam")
    get :new
    assert_response :success
  end
  
  def test_should_get_message
    login_as("sam")
    get :show, :id => messages(:abby_to_sam_1)
    assert_response :success
  end
  
  def test_should_protect_message
    login_as("sam")
    get :show, :id => messages(:abby_to_catie_1)
    assert_response :forbidden
  end
  
  def test_should_create_message
    message_count = Message.count
    login_as("sam")
    post :create, :message => {:recipient => 'abby', :subject => "hi", :body => "Abby, how was school today?"}
    assert_response :redirect
    assert_redirected_to outbox_messages_path
    assert_equal message_count + 1, Message.count
  end
  
  def test_should_delete_received_message
    message_pre_delete_state = Message.find(messages(:abby_to_sam_1))
    login_as("sam")
    delete :destroy, :id => messages(:abby_to_sam_1)
    assert_response :redirect
    message_post_delete_state = Message.find(messages(:abby_to_sam_1))
    assert_not_equal message_pre_delete_state.receiver_deleted, message_post_delete_state.receiver_deleted
  end
  
  def test_should_delete_sent_message
    message_pre_delete_state = Message.find(messages(:sam_to_abby_1))
    login_as("sam")
    delete :destroy, :id => messages(:sam_to_abby_1)
    assert_response :redirect
    message_post_delete_state = Message.find(messages(:sam_to_abby_1))
    assert_not_equal message_pre_delete_state.sender_deleted, message_post_delete_state.sender_deleted
  end

  def test_should_not_delete_message
    message_pre_delete_state = Message.find(messages(:abby_to_sam_1))
    login_as("sam")
    delete :destroy, :id => messages(:abby_to_catie_1)
    assert_response :forbidden
    message_post_delete_state = Message.find(messages(:abby_to_sam_1))
    assert_equal message_pre_delete_state.receiver_deleted, message_post_delete_state.receiver_deleted
  end
  
  def test_should_reply_to_message
    login_as("sam")
    get :reply, :id => messages(:abby_to_sam_1)
    assert_response :success
  end
  
  def test_should_not_reply_to_message
    login_as("sam")
    get :reply, :id => messages(:abby_to_catie_1)
    assert_response :forbidden
  end
end
