require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create user session" do
    post :create, :user_session => { :login => "user1", :password => "user1password" }
    assert user_session = UserSession.find
    assert_equal users(:user1), user_session.user
    assert_redirected_to user_path(users(:user1).login)
  end
  
  test "should not create user session with wrong credential" do
    post :create, :user_session => { :login => "user1", :password => "wrong password" }
    assert_nil user_session = UserSession.find
    assert_redirected_to new_user_session_url
  end
  
  test "should destroy user session" do
    delete :destroy
    assert_nil UserSession.find
    assert_redirected_to new_user_session_path
  end
end
