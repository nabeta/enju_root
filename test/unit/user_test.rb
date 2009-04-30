require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  #include AuthenticatedTestHelper
  fixtures :users, :patrons, :user_groups, :manifestation_forms, :roles

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      #assert user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password => 'new_password', :password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_not_require_email
    #assert_no_difference 'User.count' do
    assert_difference 'User.count' do
      u = create_user(:email => nil)
      assert_nil u.errors.on(:email)
    end
  end

  def test_should_reset_password
    #users(:user1).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    assert_equal users(:user1), User.authenticate('user1', 'new password')
  end

  def test_should_not_rehash_password
    users(:user1).update_attributes(:login => 'user1')
    assert_equal users(:user1), User.authenticate('user1', 'user1password')
  end

  def test_should_authenticate_user
    assert_equal users(:user1), User.authenticate('user1', 'user1password')
  end

  #def test_should_set_remember_token
  #  users(:user1).remember_me
  #  assert_not_nil users(:user1).remember_token
  #  assert_not_nil users(:user1).remember_token_expires_at
  #end

  #def test_should_unset_remember_token
  #  users(:user1).remember_me
  #  assert_not_nil users(:user1).remember_token
  #  users(:user1).forget_me
  #  assert_nil users(:user1).remember_token
  #end

  #def test_should_remember_me_for_one_week
  #  before = 1.week.from_now.utc
  #  users(:user1).remember_me_for 1.week
  #  after = 1.week.from_now.utc
  #  assert_not_nil users(:user1).remember_token
  #  assert_not_nil users(:user1).remember_token_expires_at
  #  assert users(:user1).remember_token_expires_at.between?(before, after)
  #end

  #def test_should_remember_me_until_one_week
  #  time = 1.week.from_now.utc
  #  users(:user1).remember_me_until time
  #  assert_not_nil users(:user1).remember_token
  #  assert_not_nil users(:user1).remember_token_expires_at
  #  assert_equal users(:user1).remember_token_expires_at, time
  #end

  #def test_should_remember_me_default_two_weeks
  #  before = 2.weeks.from_now.utc
  #  users(:user1).remember_me
  #  after = 2.weeks.from_now.utc
  #  assert_not_nil users(:user1).remember_token
  #  assert_not_nil users(:user1).remember_token_expires_at
  #  assert users(:user1).remember_token_expires_at.between?(before, after)
  #end

  def test_should_reset_checkout_icalendar_token
    users(:user1).reset_checkout_icalendar_token
    assert_not_nil users(:user1).checkout_icalendar_token
  end

  def test_should_reset_answer_feed_token
    users(:user1).reset_answer_feed_token
    assert_not_nil users(:user1).answer_feed_token
  end

  def test_should_delete_checkout_icalendar_token
    users(:user1).delete_checkout_icalendar_token
    assert_nil users(:user1).checkout_icalendar_token
  end

  def test_should_delete_answer_feed_token
    users(:user1).delete_answer_feed_token
    assert_nil users(:user1).answer_feed_token
  end

  def test_should_get_checked_item_count
    count = users(:user1).checked_item_count
    assert_not_nil count
  end

  def test_should_set_temporary_password
    old_password = users(:user1).crypted_password
    users(:user1).set_auto_generated_password
    assert_not_equal old_password, users(:user1).crypted_password
    assert_not_nil users(:user1).temporary_password
  end

  def test_should_get_reserves_count
    assert_equal 1, users(:user1).reserves.waiting.size
  end

  def test_should_get_highest_role
    assert_equal 'Administrator', users(:admin).highest_role.name
  end

  def test_should_send_message
    assert users(:librarian1).send_message('reservation_expired_for_patron', :manifestations => users(:librarian1).reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
    assert_equal [], users(:librarian1).reserves.not_sent_expiration_notice_to_patron
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quirepassword', :password_confirmation => 'quirepassword' }.merge(options))
    end
end
