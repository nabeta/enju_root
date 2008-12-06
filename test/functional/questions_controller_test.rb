require File.dirname(__FILE__) + '/../test_helper'
require 'questions_controller'

class QuestionsControllerTest < ActionController::TestCase
  fixtures :questions, :users, :user_groups, :roles, :roles_users, :patrons, :libraries

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
    login_as :user1
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_my_index_feed
    login_as :user1
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_index_without_user_id
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index
    login_as :user1
    get :index, :user_id => users(:user2).login
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index_feed
    login_as :user1
    get :index, :user_id => users(:user2).login, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_without_user_id
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_feed_without_user_id
    login_as :librarian1
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_new_without_user_id
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_user_should_not_get_other_new
    login_as :user1
    get :new, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_get_my_new
    login_as :user1
    get :new, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_create_question_without_login
    old_count = Question.count
    post :create, :question => { }
    assert_equal old_count, Question.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_question_without_user_id
    login_as :user1
    old_count = Question.count
    post :create, :question => { }
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_create_question_with_other_user_id
    login_as :user1
    old_count = Question.count
    post :create, :question => { }, :user_id => users(:user2).login
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_create_question_with_missing_user_id
    login_as :user1
    old_count = Question.count
    post :create, :question => { }, :user_id => 'hoge'
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_create_question_without_body
    login_as :user1
    old_count = Question.count
    post :create, :question => { }, :user_id => users(:user1).login
    assert_equal old_count, Question.count
    
    assert_response :success
  end

  def test_user_should_create_question_with_my_user_id
    login_as :user1
    old_count = Question.count
    post :create, :question => {:body => 'test'}, :user_id => users(:user1).login
    assert_equal old_count+1, Question.count
    
    assert_redirected_to user_question_url(users(:user1).login, assigns(:question))
  end

  def test_guest_should_not_show_question
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_question_without_user_id
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_user_should_show_other_question
    login_as :user1
    get :show, :id => 5, :user_id => users(:user2).login
    assert_response :success
  end

  def test_user_should_not_show_missing_question
    login_as :user1
    get :show, :id => 100, :user_id => users(:user2).login
    assert_response :missing
  end

  def test_user_should_show_my_question_with_user_id
    login_as :user1
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_show_question_with_other_user_id
    login_as :user1
    get :show, :id => 5, :user_id => users(:user2).login
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit_without_user_id
    login_as :user1
    get :edit, :id => 3
    assert_response :forbidden
  end
  
  def test_user_should_not_get_missing_edit
    login_as :user1
    get :edit, :id => 100, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    login_as :user1
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    login_as :user1
    get :edit, :id => 5, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_not_update_question_without_login
    put :update, :id => 1, :question => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_update_my_question
    login_as :user1
    put :update, :id => 3, :question => { }, :user_id => users(:user1).login
    assert_redirected_to user_question_url(users(:user1).login, assigns(:question))
  end
  
  def test_user_should_not_update_missing_question
    login_as :user1
    put :update, :id => 100, :question => { }, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_not_update_other_question
    login_as :user1
    put :update, :id => 5, :question => { }, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_not_update_without_body
    login_as :user1
    put :update, :id => 3, :question => {:body => ""}, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_guest_should_not_destroy_question
    old_count = Question.count
    delete :destroy, :id => 1
    assert_equal old_count, Question.count
    
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_destroy_question_without_user_id
    login_as :admin
    old_count = Question.count
    delete :destroy, :id => 1
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_destroy_my_question
    login_as :user1
    old_count = Question.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Question.count
    
    assert_redirected_to user_questions_url(users(:user1).login)
  end

  def test_user_should_not_destroy_without_user_id
    login_as :user1
    old_count = Question.count
    delete :destroy, :id => 3
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_destroy_other_question
    login_as :user1
    old_count = Question.count
    delete :destroy, :id => 5, :user_id => users(:user2).login
    assert_equal old_count, Question.count
    
    assert_response :forbidden
  end

  def test_user_should_not_destroy_missing_question
    login_as :user1
    old_count = Question.count
    delete :destroy, :id => 100, :user_id => users(:user1).login
    assert_equal old_count, Question.count
    
    assert_response :missing
  end
end
