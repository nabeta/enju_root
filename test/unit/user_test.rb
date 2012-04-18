require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  #include AuthenticatedTestHelper
  fixtures :users, :patrons, :user_groups, :carrier_types, :roles

  def test_should_create_user
    assert_difference 'User.count' do
      u = create_user
      assert !u.new_record?, "#{u.errors.full_messages.to_sentence}"
      #assert user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_username
    assert_no_difference 'User.count' do
      u = create_user(:username => nil)
      assert u.errors[:username]
    end
  end

  def test_should_not_require_user_number
    assert_difference 'User.count' do
      u = create_user(:user_number => nil)
      assert_blank u.errors[:user_number]
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors[:password]
    end
  end

  def test_should_not_require_password_confirmation_on_create
    assert_difference 'User.count' do
      u = create_user(:password => 'new_password', :password_confirmation => nil)
      assert_blank u.errors[:email]
    end
  end

  def test_should_not_require_email_on_create
    assert_difference 'User.count' do
      u = create_user(:email => '')
      assert_blank u.errors[:email]
    end
  end

  def test_should_reset_password
    #users(:user1).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    assert users(:user1).valid_password?('new password')
  end

  #def test_should_not_rehash_password
  #  users(:user1).update_attributes(:username => 'user1')
  #  assert users(:user1).valid_password?('user1password')
  #end

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

  def test_should_reset_answer_feed_token
    users(:user1).reset_answer_feed_token
    assert_not_nil users(:user1).answer_feed_token
  end

  def test_should_delete_answer_feed_token
    users(:user1).delete_answer_feed_token
    assert_nil users(:user1).answer_feed_token
  end

  def test_should_set_temporary_password
    old_password = users(:user1).encrypted_password
    users(:user1).set_auto_generated_password
    assert_not_equal old_password, users(:user1).encrypted_password
    assert !users(:user1).valid_password?('user1password')
  end

  def test_should_get_highest_role
    assert_equal 'Administrator', users(:admin).role.name
  end

  #def test_should_send_message
  #  assert users(:librarian1).send_message('reservation_expired_for_patron', :manifestations => users(:librarian1).reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
  #  users(:librarian1).reload
  #  assert_equal [], users(:librarian1).reserves.not_sent_expiration_notice_to_patron
  #end

  def test_should_lock_expired_users
    User.lock_expired_users
    assert_equal false, users(:user4).active_for_authentication?
  end

  protected
  def create_user(options = {})
    user = User.new({ :username => 'quire', :email => 'quire@example.com', :email_confirmation => 'quire@example.com', :password => 'quirepassword', :password_confirmation => 'quirepassword', :user_number => '99999' }.merge(options))
    user.operator = users(:admin)
    user.save
    user
  end

end
# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer         default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  authentication_token   :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  deleted_at             :datetime
#  username               :string(255)
#  library_id             :integer         default(1), not null
#  user_group_id          :integer         default(1), not null
#  expired_at             :datetime
#  required_role_id       :integer         default(1), not null
#  note                   :text
#  keyword_list           :text
#  user_number            :string(255)
#  state                  :string(255)
#  required_score         :integer         default(0), not null
#  locale                 :string(255)
#  openid_identifier      :string(255)
#  oauth_token            :string(255)
#  oauth_secret           :string(255)
#  active                 :boolean         default(FALSE)
#  enju_access_key        :string(255)
#

