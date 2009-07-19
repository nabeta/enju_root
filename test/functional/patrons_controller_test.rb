require 'test_helper'

class PatronsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :patrons, :users, :patron_types, :manifestations, :carrier_types, :expressions, :works, :embodies, :roles,
    :creates, :realizes, :produces, :owns, :languages, :countries

  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_guest_should_get_index_with_query
    get :index, :query => 'Librarian1'
    assert_response :success
  end

  def test_guest_should_get_index_with_patron
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:patrons)
  end

  def test_guest_should_get_index_with_work
    get :index, :work_id => 1
    assert_response :success
  end

  def test_guest_should_get_index_with_expression
    get :index, :expression_id => 1
    assert_response :success
  end

  def test_guest_should_get_index_with_manifestation
    get :index, :manifestation_id => 1
    assert_response :success
  end

  #def test_guest_should_get_recent_index
  #  get :index, :recent => true
  #  assert_response :success
  #end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:patrons)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
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
    assert_response :success
  end
  
  def test_guest_should_not_create_patron
    old_count = Patron.count
    post :create, :patron => { :full_name => 'test' }
    assert_equal old_count, Patron.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_create_patron_myself
    UserSession.create users(:user1)
    assert_difference('Patron.count') do
      post :create, :patron => { :full_name => 'test', :user_id => users(:user1).login }
    end
    
    assert_response :redirect
    assert_equal assigns(:patron).user, users(:user1)
    assert_redirected_to patron_url(assigns(:patron))
  end

  def test_user_should_not_create_patron_without_user_id
    UserSession.create users(:user1)
    assert_no_difference('Patron.count') do
      post :create, :patron => { :full_name => 'test' }
    end
    
    assert_response :forbidden
  end

  def test_user_should_not_create_other_patron
    UserSession.create users(:user1)
    assert_no_difference('Patron.count') do
      post :create, :patron => { :full_name => 'test', :user_id => users(:user2).login }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_create_patron
    UserSession.create users(:librarian1)
    assert_difference('Patron.count') do
      post :create, :patron => { :full_name => 'test' }
    end
    
    assert_redirected_to patron_url(assigns(:patron))
  end

  # TODO: full_name以外での判断
  def test_librarian_should_create_patron_without_full_name
    UserSession.create users(:librarian1)
    assert_difference('Patron.count') do
      post :create, :patron => { :first_name => 'test' }
    end
    
    assert_redirected_to patron_url(assigns(:patron))
  end

  def test_guest_should_show_patron
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_show_patron_when_required_role_is_user
    get :show, :id => 5
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_show_patron_with_work
    get :show, :id => 1, :work_id => 1
    assert_response :success
  end

  def test_guest_should_show_patron_with_expression
    get :show, :id => 1, :expression_id => 1
    assert_response :success
  end

  def test_guest_should_show_patron_with_manifestation
    get :show, :id => 1, :manifestation_id => 1
    assert_response :success
  end

  def test_user_should_show_patron
    UserSession.create users(:user1)
    get :show, :id => users(:user2).patron
    assert_response :success
  end

  def test_user_should_not_show_patron_when_required_role_is_librarian
    UserSession.create users(:user2)
    get :show, :id => users(:user1).patron
    assert_response :forbidden
  end

  def test_user_should_show_myself
    UserSession.create users(:user1)
    get :show, :id => users(:user1).patron
    assert_response :success
  end

  def test_librarian_should_show_patron_when_required_role_is_user
    UserSession.create users(:librarian1)
    get :show, :id => users(:user2).patron
    assert_response :success
  end

  def test_librarian_should_show_patron_when_required_role_is_librarian
    UserSession.create users(:librarian1)
    get :show, :id => users(:user1).patron
    assert_response :success
  end

  def test_librarian_should_not_show_patron_when_required_role_is_admin
    UserSession.create users(:librarian2)
    get :show, :id => users(:librarian1).patron
    assert_response :forbidden
  end

  def test_librarian_should_not_show_patron_not_create
    UserSession.create users(:librarian1)
    get :show, :id => 2, :work_id => 3
    assert_response :missing
    #assert_redirected_to new_patron_create_url(assigns(:patron), :work_id => 3)
  end

  def test_librarian_should_not_show_patron_not_realize
    UserSession.create users(:librarian1)
    get :show, :id => 2, :expression_id => 4
    assert_response :missing
  end

  def test_librarian_should_not_show_patron_not_produce
    UserSession.create users(:librarian1)
    get :show, :id => 2, :manifestation_id => 4
    assert_response :missing
    #assert_redirected_to new_patron_produce_url(assigns(:patron), :manifestation_id => 4)
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
  end
  
  def test_user_should_get_edit_myself
    UserSession.create users(:user1)
    get :edit, :id => users(:user1).patron
    assert_response :success
  end
  
  def test_user_should_not_get_edit_other_patron
    UserSession.create users(:user1)
    get :edit, :id => users(:user2).patron
    assert_response :forbidden
  end

  def test_librarian_should_edit_patron_when_required_role_is_user
    UserSession.create users(:librarian1)
    get :edit, :id => users(:user2).patron
    assert_response :success
  end

  def test_librarian_should_edit_patron_when_required_role_is_librarian
    UserSession.create users(:librarian1)
    get :edit, :id => users(:user1).patron
    assert_response :success
  end
  
  def test_librarian_should_not_get_edit_admin
    UserSession.create users(:librarian1)
    get :edit, :id => users(:admin).patron
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_patron
    put :update, :id => 1, :patron => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_myself
    UserSession.create users(:user1)
    put :update, :id => users(:user1).patron.id, :patron => { :full_name => 'test' }
    assert_redirected_to patron_url(assigns(:patron))
  end
  
  def test_user_should_not_update_myself_without_name
    UserSession.create users(:user1)
    put :update, :id => users(:user1).patron.id, :patron => { :first_name => '', :last_name => '', :full_name => '' }
    assert_response :success
  end
  
  def test_user_should_not_update_other_patron
    UserSession.create users(:user1)
    put :update, :id => users(:user2).patron.id, :patron => { :full_name => 'test' }
    assert_response :forbidden
  end
  
  def test_guest_should_not_destroy_patron
    old_count = Patron.count
    delete :destroy, :id => 1
    assert_equal old_count, Patron.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_patron
    UserSession.create users(:user1)
    old_count = Patron.count
    delete :destroy, :id => users(:user1).patron
    assert_equal old_count, Patron.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_patron
    UserSession.create users(:librarian1)
    old_count = Patron.count
    delete :destroy, :id => users(:user1).patron
    assert_equal old_count-1, Patron.count
    
    assert_redirected_to patrons_url
  end

  def test_librarian_should_not_destroy_librarian
    UserSession.create users(:librarian1)
    old_count = Patron.count
    delete :destroy, :id => users(:librarian1).patron
    assert_equal old_count, Patron.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_librarian
    UserSession.create users(:admin)
    old_count = Patron.count
    delete :destroy, :id => users(:librarian1).patron
    assert_equal old_count-1, Patron.count
    
    assert_redirected_to patrons_url
  end
end
