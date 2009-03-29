require 'test_helper'

class FrequencyOfIssuesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :frequency_of_issues, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:frequency_of_issues)
  end

  def test_librarian_should_not_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:frequency_of_issues)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:frequency_of_issues)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    UserSession.create users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    UserSession.create users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    UserSession.create users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_frequency_of_issue
    old_count = FrequencyOfIssue.count
    post :create, :frequency_of_issue => { }
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_frequency_of_issue
    UserSession.create users(:user1)
    old_count = FrequencyOfIssue.count
    post :create, :frequency_of_issue => { }
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_frequency_of_issue
    UserSession.create users(:librarian1)
    old_count = FrequencyOfIssue.count
    post :create, :frequency_of_issue => { }
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_frequency_of_issue_without_name
    UserSession.create users(:admin)
    old_count = FrequencyOfIssue.count
    post :create, :frequency_of_issue => { }
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_response :success
  end

  def test_admin_should_create_frequency_of_issue
    UserSession.create users(:admin)
    old_count = FrequencyOfIssue.count
    post :create, :frequency_of_issue => {:name => 'test'}
    assert_equal old_count+1, FrequencyOfIssue.count
    
    assert_redirected_to frequency_of_issue_url(assigns(:frequency_of_issue))
  end

  def test_guest_should_show_frequency_of_issue
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_frequency_of_issue
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_frequency_of_issue
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_frequency_of_issue
    UserSession.create users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_frequency_of_issue
    put :update, :id => 1, :frequency_of_issue => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_frequency_of_issue
    UserSession.create users(:user1)
    put :update, :id => 1, :frequency_of_issue => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_frequency_of_issue
    UserSession.create users(:librarian1)
    put :update, :id => 1, :frequency_of_issue => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_frequency_of_issue_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :frequency_of_issue => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_frequency_of_issue
    UserSession.create users(:admin)
    put :update, :id => 1, :frequency_of_issue => { }
    assert_redirected_to frequency_of_issue_url(assigns(:frequency_of_issue))
  end
  
  def test_guest_should_not_destroy_frequency_of_issue
    old_count = FrequencyOfIssue.count
    delete :destroy, :id => 1
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_frequency_of_issue
    UserSession.create users(:user1)
    old_count = FrequencyOfIssue.count
    delete :destroy, :id => 1
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_frequency_of_issue
    UserSession.create users(:librarian1)
    old_count = FrequencyOfIssue.count
    delete :destroy, :id => 1
    assert_equal old_count, FrequencyOfIssue.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_frequency_of_issue
    UserSession.create users(:admin)
    old_count = FrequencyOfIssue.count
    delete :destroy, :id => 1
    assert_equal old_count-1, FrequencyOfIssue.count
    
    assert_redirected_to frequency_of_issues_url
  end
end
