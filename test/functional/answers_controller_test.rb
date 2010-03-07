require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :answers, :questions, :languages, :patrons, :patron_types, :user_groups, :users, :roles, :library_groups, :libraries, :countries

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_get_other_index_without_question_id
    get :index, :user_id => users(:user1).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_get_other_index_without_user_id
    get :index, :question_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_index_without_user_id
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_without_user_id
    UserSession.create users(:user1)
    get :index, :user_id => users(:user2).login
    assert_response :forbidden
  end

  def test_librarian_should_get_index_without_user_id
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index_without_question_id
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index_feed
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_if_question_is_not_shared
    UserSession.create users(:user1)
    get :index, :user_id => users(:librarian1).login, :question_id => 2
    assert_response :forbidden
  end

  def test_user_should_get_other_index_if_question_is_shared
    UserSession.create users(:user1)
    get :index, :user_id => users(:user2).login, :question_id => 5
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_feed_if_question_is_not_shared
    UserSession.create users(:user1)
    get :index, :user_id => users(:librarian1).login, :question_id => 2, :format => 'rss'
    #assert_response :forbidden
    assert_response :not_acceptable
  end

  def test_user_should_get_other_index_feed_if_question_is_shared
    UserSession.create users(:user1)
    get :index, :user_id => users(:user2).login, :question_id => 5, :format => 'rss'
    assert_response :success
    assert assigns(:answers)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_new_without_question_id
    UserSession.create users(:user1)
    get :new
    assert_response :redirect
    assert_redirected_to questions_url
  end
  
  def test_user_should_get_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:user2).login, :question_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_answer
    old_count = Answer.count
    post :create, :answer => { }
    assert_equal old_count, Answer.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_create_answer_without_user_id
    UserSession.create users(:user1)
    old_count = Answer.count
    post :create, :answer => {:question_id => 1, :body => 'hoge'}
    assert_equal old_count+1, Answer.count
    
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.login, assigns(:answer).question, assigns(:answer))
  end

  def test_user_should_not_create_answer_without_question_id
    UserSession.create users(:user1)
    old_count = Answer.count
    post :create, :answer => {:body => 'hoge'}
    assert_equal old_count, Answer.count
    
    assert_response :redirect
    assert_redirected_to questions_url
  end

  def test_user_should_create_answer_with_question_id
    UserSession.create users(:user1)
    old_count = Answer.count
    post :create, :answer => {:question_id => 1, :body => 'hoge'}
    assert_equal old_count+1, Answer.count
    
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.login, assigns(:answer).question, assigns(:answer))
  end

  def test_guest_should_show_public_answer
    get :show, :id => 1, :question_id => 1
    assert_response :success
  end

  def test_guest_should_not_show_private_answer
    get :show, :id => 4, :question_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_answer_without_user_id
    UserSession.create users(:user1)
    get :show, :id => 1, :question_id => 1
    assert_response :success
  end

  def test_user_should_show_public_answer_without_question_id
    UserSession.create users(:user1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_show_my_answer
    UserSession.create users(:user1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_show_other_public_answer
    UserSession.create users(:user1)
    get :show, :id => 5, :user_id => users(:user2).login
    assert_response :success
  end

  def test_user_should_not_show_private_answer
    UserSession.create users(:user1)
    get :show, :id => 4, :user_id => users(:user1).login
    assert_response :forbidden
  end

  def test_user_should_not_show_missing_answer
    UserSession.create users(:user1)
    get :show, :id => 100, :user_id => users(:user1).login, :question_id => 1
    assert_response :missing
  end

  def test_user_should_not_show_answer_with_other_user_id
    UserSession.create users(:user1)
    get :show, :id => 5, :user_id => users(:user2).login, :question_id => 2
    assert_response :forbidden
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_my_edit_without_user_id
    UserSession.create users(:user1)
    get :edit, :id => 3, :question_id => 1
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit_without_user_id
    UserSession.create users(:user1)
    get :edit, :id => 4, :question_id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_edit_without_question_id
    UserSession.create users(:user1)
    get :edit, :id => 3 , :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_get_missing_edit
    UserSession.create users(:user1)
    get :edit, :id => 100, :user_id => users(:user1).login, :question_id => 1
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    UserSession.create users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).login, :question_id => 1
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    UserSession.create users(:user1)
    get :edit, :id => 5, :user_id => users(:user2).login, :question_id => 2
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_answer
    put :update, :id => 1, :answer => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_answer
    UserSession.create users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).login
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.login, assigns(:answer).question, assigns(:answer))
  end
  
  def test_user_should_update_my_answer_with_question_id
    UserSession.create users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).login, :question_id => 1
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.login, assigns(:answer).question, assigns(:answer))
    #assert_redirected_to answer_url(assigns(:answer))
  end
  
  def test_user_should_not_update_missing_answer
    UserSession.create users(:user1)
    put :update, :id => 100, :answer => { }, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_not_update_other_answer
    UserSession.create users(:user1)
    put :update, :id => 5, :answer => { }, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_user_should_not_update_answer_without_body
    UserSession.create users(:user1)
    put :update, :id => 3, :answer => {:body => nil}, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_librarian_should_update_other_answer
    UserSession.create users(:librarian1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).login
  #  assert_redirected_to answer_url(assigns(:answer))
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.login, assigns(:answer).question, assigns(:answer))
  end
  
  def test_guest_should_not_destroy_answer
    old_count = Answer.count
    delete :destroy, :id => 1
    assert_equal old_count, Answer.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_answer
    UserSession.create users(:user1)
    old_count = Answer.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Answer.count
    
    assert_redirected_to user_question_answers_url(assigns(:answer).question.user.login, assigns(:answer).question)
  end

  def test_user_should_not_destroy_other_answer
    UserSession.create users(:user1)
    old_count = Answer.count
    delete :destroy, :id => 5, :user_id => users(:user2).login
    assert_equal old_count, Answer.count
    
    assert_response :forbidden
  end

  #def test_everyone_should_not_destroy_missing_answer
  #  UserSession.create users(:admin)
  #  old_count = Answer.count
  #  delete :destroy, :id => 100, :user_id => users(:user1).login
  #  assert_equal old_count, Answer.count
  #  
  #  assert_response :missing
  #end
end
