require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :questions, :users, :user_groups, :roles, :patrons, :libraries

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_get_index_with_query
    get :index, :query => 'Yahoo'
    assert_response :success
    assert assigns(:questions)
    assert assigns(:resources)
  end

  def test_user_should_get_my_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_my_index_feed
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_index_without_user_id
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user2).login
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index_feed
    UserSession.create users(:user1)
    get :index, :user_id => users(:user2).login, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_without_user_id
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_feed_without_user_id
    UserSession.create users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_new
    UserSession.create users(:user1)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_question
    old_count = Question.count
    post :create, :question => { }
    assert_equal old_count, Question.count
    
    assert_redirected_to new_user_session_url
  end


  def test_user_should_not_create_question_without_body
    UserSession.create users(:user1)
    old_count = Question.count
    post :create, :question => { }
    assert_equal old_count, Question.count
    
    assert_response :success
  end

  def test_user_should_create_question_with_body
    UserSession.create users(:user1)
    old_count = Question.count
    post :create, :question => {:body => 'test'}
    assert_equal old_count+1, Question.count
    
    assert_redirected_to user_question_url(users(:user1).login, assigns(:question))
  end

  def test_guest_should_not_show_question
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_question_without_user_id
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_user_should_show_other_question
    UserSession.create users(:user1)
    get :show, :id => 5, :user_id => users(:user2).login
    assert_response :success
  end

  def test_user_should_not_show_missing_question
    UserSession.create users(:user1)
    get :show, :id => 100, :user_id => users(:user2).login
    assert_response :missing
  end

  def test_user_should_show_my_question_with_user_id
    UserSession.create users(:user1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_show_question_with_other_user_id
    UserSession.create users(:user1)
    get :show, :id => 5, :user_id => users(:user2).login
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit_other_question
    UserSession.create users(:user1)
    get :edit, :id => 5
    assert_response :forbidden
  end
  
  def test_user_should_not_get_missing_edit
    UserSession.create users(:user1)
    get :edit, :id => 100, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    UserSession.create users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    UserSession.create users(:user1)
    get :edit, :id => 5, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_not_update_question_without_login
    put :update, :id => 1, :question => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_question
    UserSession.create users(:user1)
    put :update, :id => 3, :question => { }, :user_id => users(:user1).login
    assert_redirected_to user_question_url(users(:user1).login, assigns(:question))
  end
  
  def test_user_should_not_update_missing_question
    UserSession.create users(:user1)
    put :update, :id => 100, :question => { }, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_not_update_other_question
    UserSession.create users(:user1)
    put :update, :id => 5, :question => { }, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_not_update_without_body
    UserSession.create users(:user1)
    put :update, :id => 3, :question => {:body => ""}, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_guest_should_not_destroy_question
    old_count = Question.count
    delete :destroy, :id => 1
    assert_equal old_count, Question.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_question
    UserSession.create users(:user1)
    old_count = Question.count
    delete :destroy, :id => 3
    assert_equal old_count-1, Question.count
    
    assert_redirected_to user_questions_url(assigns(:question).user.login)
  end

  def test_user_should_not_destroy_other_question
    UserSession.create users(:user1)
    old_count = Question.count
    delete :destroy, :id => 5, :user_id => users(:user2).login
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_destroy_missing_question
    UserSession.create users(:user1)
    old_count = Question.count
    delete :destroy, :id => 100, :user_id => users(:user1).login
    assert_equal old_count, Question.count
    
    assert_response :missing
  end
end
