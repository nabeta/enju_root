require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < Test::Unit::TestCase

  fixtures :users, :messages

  def test_should_mark_message_read
    m = messages(:user2_to_user1_1)
    assert_nil m.read_at
    m.mark_message_read(users(:user1))
    assert_not_nil m.read_at
  end

  def test_should_purge_message
    m = messages(:user2_to_user1_Trash_2)
    n = m.id
    assert_not_nil m
    m.purge
    m = Message.find_by_id(n)
    assert_nil m
  end

  def test_should_require_body
    assert_no_difference Message, :count do
      m = create_message(:body => nil)
      assert m.errors.on(:body)
    end
  end

  def test_should_require_recipient
    assert_no_difference Message, :count do
      m = create_message(:recipient => nil)
      assert m.errors.on(:recipient)
    end
  end
  
  def test_should_require_subject
    assert_no_difference Message, :count do
      m = create_message(:subject => nil)
      assert m.errors.on(:subject)
    end
  end
  
  def test_should_return_sender_name
    m = create_message
    assert_not_nil m.sender_name
  end
  
  def test_should_return_receiver_name
    m = create_message
    m.receiver = users(:user1)
    assert_not_nil m.receiver_name
  end
  
  
  protected
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def create_message(options = {})
    Message.create({ :recipient => users(:user1).login, :sender => users(:user2), :subject => 'new message', :body => 'new message body is really short' }.merge(options))
  end
end
