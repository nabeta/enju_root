require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.

  setup :activate_authlogic
  fixtures :users, :roles, :patrons, :libraries, :checkouts, :checkins, :patron_types, :advertisements, :tags, :taggings,
    :manifestations, :carrier_types, :expressions, :embodies, :works, :realizes, :creates, :reifies, :produces

  #def test_should_allow_signup
  #  assert_difference 'User.count' do
  #    create_user
  #    assert_response :redirect
  #  end
  #end

  def test_user_should_not_allow_signup
    UserSession.create users(:user1)
    assert_no_difference 'User.count' do
      create_user
      assert_response :forbidden
    end
  end

  def test_librarian_should_allow_signup_without_patron_id
    UserSession.create users(:librarian1)
    assert_difference 'User.count' do
      create_user_without_patron_id
      assert_response :redirect
      assert_redirected_to new_user_patron_url(assigns(:user).login)
    end
    assigns(:user).remove_from_index!
  end

  #def test_librarian_should_not_allow_signup_without_patron_id_and_name
  #  UserSession.create users(:librarian1)
  #  assert_no_difference 'User.count' do
  #    create_user_without_patron_id_and_name
  #    assert_response :success
  #  end
  #end

  def test_librarian_should_allow_signup_without_patron_id
    UserSession.create users(:librarian1)
    assert_difference 'User.count' do
      create_user_without_patron_id
      assert_response :redirect
      assert_redirected_to user_url(assigns(:user).login)
    end
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_require_login_on_signup
    UserSession.create users(:librarian1)
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_librarian_should_not_require_password_on_signup
    UserSession.create users(:librarian1)
    assert_difference 'User.count' do
      create_user(:password => nil)
      #assert_response :success
      assert_response :redirect
      assert_redirected_to user_url(assigns(:user).login)
    end
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_not_require_password_confirmation_on_signup
    UserSession.create users(:librarian1)
    assert_difference 'User.count' do
      create_user(:password_confirmation => nil)
      #assert assigns(:user).errors.on(:password_confirmation)
      #assert_response :success
      assert_response :redirect
      assert_redirected_to user_url(assigns(:user).login)
    end
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_not_require_email_on_signup
    UserSession.create users(:librarian1)
    assert_difference 'User.count' do
      create_user(:email => nil)
      #assert assigns(:user).errors.on(:email)
      #assert_response :success
      assert_response :redirect
      assert_redirected_to user_url(assigns(:user).login)
    end
    assigns(:user).remove_from_index!
  end
  
  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:users)
  end

  def test_guest_should_not_update_user
    put :update, :id => 'admin', :user => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_update_myself
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => { }
    assert_redirected_to user_url(assigns(:user).login)
    assigns(:user).remove_from_index!
  end

  #def test_user_should_not_update_myself_without_login
  #  UserSession.create users(:user1)
  #  put :update, :id => users(:user1).login, :user => {:login => ""}
  #  assert_redirected_to user_url(assigns(:user).login)
  #  assert_equal assigns(:user).login, users(:user1).login
  #end

  def test_user_should_update_myself_without_email
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:email => ""}
    #assert_response :success
    assert_redirected_to user_url(assigns(:user).login)
    assert assigns(:user).valid_password?('user1password')
    assigns(:user).remove_from_index!
  end

  def test_user_should_update_my_password
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:email => 'user1@library.example.jp', :old_password => 'user1password', :password => 'new_user1', :password_confirmation => 'new_user1'}
    assert_redirected_to user_url(assigns(:user).login)
    assert_equal 'User was successfully updated.', flash[:notice]
    assert assigns(:user).valid_password?('new_user1')
    assert !assigns(:user).valid_password?('user1password')
    assigns(:user).remove_from_index!
  end

  def test_user_should_not_update_my_password_without_current_password
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:email => 'user1@library.example.jp', :old_password => 'wrong password', :password => 'new_user1', :password_confirmation => 'new_user1'}
    assert_response :success
    assert assigns(:user).valid_password?('user1password')
    assert !assigns(:user).valid_password?('new_user1')
    assert !assigns(:user).valid_password?('wrong password')
  end

  def test_user_should_not_update_my_password_without_password_confirmation
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:email => 'user1@library.example.jp', :old_password => 'user1password', :password => 'new_user1', :password_confirmation => 'wrong password'}
    assert_response :success
    assert_equal assigns(:user).errors[:password], "doesn't match confirmation"
    assert assigns(:user).valid_password?('user1password')
    assert !assigns(:user).valid_password?('new_user1')
    assert !assigns(:user).valid_password?('wrong password')
  end

  def test_user_should_not_update_my_role
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:role_id => 4}
    assert_redirected_to user_url(assigns(:user).login)
    assert !assigns(:user).roles.include?(Role.find(4))
  end

  def test_user_should_not_update_my_user_group
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:user_group_id => 3}
    assert_redirected_to user_url(assigns(:user).login)
    assert_equal assigns(:user).user_group.id, 1
  end

  def test_user_should_not_update_my_note
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:note => 'test'}
    assert_redirected_to user_url(assigns(:user).login)
    assert_nil assigns(:user).note
  end

  def test_user_should_update_my_keyword_list
    UserSession.create users(:user1)
    put :update, :id => users(:user1).login, :user => {:keyword_list => 'test'}
    assert_redirected_to user_url(assigns(:user).login)
    assert_equal assigns(:user).keyword_list, 'test'
    assigns(:user).remove_from_index!
  end

  def test_user_should_not_update_other_user
    UserSession.create users(:user1)
    put :update, :id => users(:user2).login, :user => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_other_user
    UserSession.create users(:librarian1)
    put :update, :id => users(:user1).login, :user => {:user_number => '00003', :locale => 'en'}
    assert_redirected_to user_url(assigns(:user).login)
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_not_update_other_role
    UserSession.create users(:librarian1)
    put :update, :id => users(:user1).login, :user => {:role_id => 4, :locale => 'en'}
    assert_redirected_to user_url(assigns(:user).login)
    assert !assigns(:user).roles.include?(Role.find(4))
  end

  def test_admin_should_update_other_role
    UserSession.create users(:admin)
    put :update, :id => users(:user1).login, :user => {:role_id => 4, :locale => 'en'}
    assert_redirected_to user_url(assigns(:user).login)
    assert assigns(:user).roles.include?(Role.find(4))
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_update_other_user_group
    UserSession.create users(:librarian1)
    put :update, :id => users(:user1).login, :user => {:user_group_id => 3, :locale => 'en'}
    assert_redirected_to user_url(assigns(:user).login)
    assert_equal assigns(:user).user_group_id, 3
    assigns(:user).remove_from_index!
  end

  def test_librarian_should_update_other_note
    UserSession.create users(:librarian1)
    put :update, :id => users(:user1).login, :user => {:note => 'test', :locale => 'en'}
    assert_redirected_to user_url(assigns(:user).login)
    assert_equal assigns(:user).note, 'test'
    assigns(:user).remove_from_index!
  end

  def test_guest_should_get_new
    get :new, :patron_id => 6
    assert_response :success
  end

  def test_librarian_should_get_new_without_patron_id
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end

  def test_user_should_not_get_new
    UserSession.create users(:user1)
    get :new, :patron_id => 6
    assert_response :forbidden
  end

  def test_librarian_should_get_new
    UserSession.create users(:librarian1)
    get :new, :patron_id => 6
    assert_response :success
  end

  def test_guest_should_not_show_user
    get :show, :id => users(:user1).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_my_user
    UserSession.create users(:user1)
    get :show, :id => users(:user1).login
    assert_response :success
  end

  def test_user_should_show_other_user
    UserSession.create users(:user1)
    get :show, :id => users(:admin).login
    assert_response :success
  end

  def test_everyone_should_not_show_missing_user
    UserSession.create users(:admin)
    get :show, :id => 100
    assert_response :missing
  end

  def test_guest_should_not_edit_user
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_edit_missing_user
    UserSession.create users(:admin)
    get :edit, :id => 100
    assert_response :missing
  end

  def test_user_should_edit_my_user
    UserSession.create users(:user1)
    get :edit, :id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_show_other_user
    UserSession.create users(:user1)
    get :edit, :id => users(:user2).login
    assert_response :forbidden
  end

  def test_librarian_should_edit_other_user
    UserSession.create users(:librarian1)
    get :edit, :id => users(:user1).login
    assert_response :success
  end

  def test_guest_should_not_destroy_user
    old_count = User.count
    delete :destroy, :id => 1
    assert_equal old_count, User.count
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_myself
    UserSession.create users(:user1)
    old_count = User.count
    delete :destroy, :id => users(:user1).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_user_should_not_destroy_other_user
    UserSession.create users(:user1)
    old_count = User.count
    delete :destroy, :id => users(:user2).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_myself
    UserSession.create users(:librarian1)
    old_count = User.count
    delete :destroy, :id => users(:librarian1).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_librarian_should_destroy_user
    UserSession.create users(:librarian1)
    old_count = User.count
    delete :destroy, :id => users(:user2).login
    assert_equal old_count-1, User.count
    assert_redirected_to users_url
  end

  def test_librarian_should_not_destroy_user_who_has_items_not_checked_in
    UserSession.create users(:librarian1)
    old_count = User.count
    delete :destroy, :id => users(:user1).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_librarian
    UserSession.create users(:librarian1)
    old_count = User.count
    delete :destroy, :id => users(:librarian2).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_admin
    UserSession.create users(:librarian1)
    old_count = User.count
    delete :destroy, :id => users(:admin).login
    assert_equal old_count, User.count
    assert_response :forbidden
  end

  def test_admin_should_destroy_librarian
    UserSession.create users(:admin)
    old_count = User.count
    delete :destroy, :id => users(:librarian2).login
    assert_equal old_count-1, User.count
    assert_redirected_to users_url
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quirequire', :password_confirmation => 'quirequire', :patron_id => 6, :user_number => '00008' }.merge(options)
    end

    def create_user_without_patron_id_and_name(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quirequire', :password_confirmation => 'quirequire', :user_number => '00008' }.merge(options)
    end

    def create_user_without_patron_id(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quirequire', :password_confirmation => 'quirequire', :user_number => '00008', :first_name => 'quire', :last_name => 'quire' }.merge(options)
    end
end
