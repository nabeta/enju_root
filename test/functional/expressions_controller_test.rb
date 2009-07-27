require 'test_helper'

class ExpressionsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :expressions, :expression_forms, :languages, :frequencies,
    :works, :work_forms, :embodies, :realizes, :reifies,
    :manifestations, :carrier_types, :embodies,
    :patrons, :users, :languages

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_guest_should_get_index_with_query
    get :index, :query => "2005"
    assert_response :success
    assert assigns(:expressions)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:work)
    assert assigns(:expressions)
  end

  def test_guest_should_get_index_with_expression_id
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:expression)
    assert assigns(:expressions)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:expressions)
  end

  def test_guest_should_not_get_index_with_missing_manifestation
    get :index, :manifestation_id => 100
    assert_response :missing
  end

  def test_guest_should_get_index_with_patron
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:expressions)
  end

  def test_guest_should_get_index_with_missing_patron
    get :index, :patron_id => 100
    assert_response :missing
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:expressions)
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
  
  #def test_librarian_should_not_get_new_without_work_id
  #  UserSession.create users(:librarian1)
  #  get :new
  #  assert_response :redirect
  #  assert_redirected_to works_path
  #end
  
  def test_librarian_should_get_new_without_work_id
    UserSession.create users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_librarian_should_get_new_with_work_id
    UserSession.create users(:librarian1)
    get :new, :work_id => 1
    assert_response :success
  end
  
  def test_admin_should_get_new_with_work_id
    UserSession.create users(:admin)
    get :new, :work_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_expression
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count, Expression.count
    
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_expression_without_work_id
    UserSession.create users(:admin)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1 }
    assert_equal old_count, Expression.count
    
    assert_response :redirect
    assert_redirected_to works_path
  end

  def test_user_should_not_create_expression
    UserSession.create users(:user1)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count, Expression.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_expression
    UserSession.create users(:librarian1)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert_redirected_to expression_patrons_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end

  def test_librarian_should_create_expression_without_expression_form_id
    UserSession.create users(:librarian1)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :language_id => 1}, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert assigns(:expression)
    assert assigns(:expression).expression_form
    assert assigns(:expression).reify
    assert_redirected_to expression_patrons_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end

  def test_librarian_should_create_expression_without_language_id
    UserSession.create users(:librarian1)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1 }, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert assigns(:expression)
    assert assigns(:expression).language
    assert assigns(:expression).reify
    assert_redirected_to expression_patrons_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end

  def test_admin_should_create_expression
    UserSession.create users(:admin)
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1 }, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert_redirected_to expression_patrons_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end

  def test_guest_should_show_expression
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_expression
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_expression_with_manifestation_not_embody
    UserSession.create users(:librarian1)
    get :show, :id => 1, :manifestation_id => 5
    assert_response :missing
  end

  def test_librarian_should_show_expression_with_patron_not_realize
    UserSession.create users(:librarian1)
    get :show, :id => 1, :patron_id => 2
    assert_response :missing
  end

  def test_librarian_should_show_expression
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_expression
    UserSession.create users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    UserSession.create users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_expression
    put :update, :id => 1, :expression => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_expression
    UserSession.create users(:user1)
    put :update, :id => 1, :expression => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_expression_without_expression_form_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :expression => {:expression_form_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_expression_without_language_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :expression => {:language_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_expression
    UserSession.create users(:librarian1)
    put :update, :id => 1, :expression => { }
    assert_redirected_to expression_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end
  
  def test_admin_should_update_expression
    UserSession.create users(:admin)
    put :update, :id => 1, :expression => { }
    assert_redirected_to expression_url(assigns(:expression))
    assigns(:expression).remove_from_index!
  end
  
  def test_guest_should_not_destroy_expression
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count, Expression.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_expression
    UserSession.create users(:user1)
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count, Expression.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_expression
    UserSession.create users(:librarian1)
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Expression.count
    
    assert_redirected_to expressions_url
  end

  def test_admin_should_destroy_expression
    UserSession.create users(:admin)
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Expression.count
    
    assert_redirected_to expressions_url
  end
end
