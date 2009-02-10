require File.dirname(__FILE__) + '/../test_helper'
require 'expressions_controller'

class ExpressionsControllerTest < ActionController::TestCase
  fixtures :expressions, :expression_forms, :languages, :frequency_of_issues,
    :works, :work_forms, :embodies, :realizes, :reifies,
    :manifestations, :manifestation_forms, :embodies,
    :patrons, :users, :languages
  fixtures :people, :corporate_bodies, :families

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
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:expressions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_new_without_work_id
    login_as :librarian1
    get :new
    assert_response :redirect
    assert_redirected_to works_path
  end
  
  def test_librarian_should_get_new_with_work_id
    login_as :librarian1
    get :new, :work_id => 1
    assert_response :success
  end
  
  def test_admin_should_get_new_with_work_id
    login_as :admin
    get :new, :work_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_expression
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count, Expression.count
    
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_create_expression_without_work_id
    login_as :admin
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1 }
    assert_equal old_count, Expression.count
    
    assert_response :redirect
    assert_redirected_to works_path
  end

  def test_user_should_not_create_expression
    login_as :user1
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count, Expression.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_expression
    login_as :librarian1
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1}, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert_redirected_to expression_patrons_url(assigns(:expression))
  end

  def test_librarian_should_create_expression_without_expression_form_id
    login_as :librarian1
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :language_id => 1}, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert assigns(:expression)
    assert assigns(:expression).expression_form
    assert assigns(:expression).reify
    assert_redirected_to expression_patrons_url(assigns(:expression))
  end

  def test_librarian_should_create_expression_without_language_id
    login_as :librarian1
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1 }, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert assigns(:expression)
    assert assigns(:expression).language
    assert assigns(:expression).reify
    assert_redirected_to expression_patrons_url(assigns(:expression))
  end

  def test_admin_should_create_expression
    login_as :admin
    old_count = Expression.count
    post :create, :expression => { :original_title => 'test', :expression_form_id => 1, :language_id => 1 }, :work_id => 1
    assert_equal old_count+1, Expression.count
    
    assert_redirected_to expression_patrons_url(assigns(:expression))
  end

  def test_guest_should_show_expression
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_show_expression_with_issn
    get :show, :issn => "00000000"
    assert_response :redirect
    assert_redirected_to expression_url(assigns(:expression))
  end

  def test_user_should_show_expression
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_expression_with_manifestation_not_embody
    login_as :librarian1
    get :show, :id => 1, :manifestation_id => 5
    assert_response :missing
  end

  def test_librarian_should_show_expression_with_patron_not_realize
    login_as :librarian1
    get :show, :id => 1, :patron_id => 2
    assert_response :missing
  end

  def test_librarian_should_show_expression
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_expression
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_expression
    put :update, :id => 1, :expression => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_expression
    login_as :user1
    put :update, :id => 1, :expression => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_expression_without_expression_form_id
    login_as :librarian1
    put :update, :id => 1, :expression => {:expression_form_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_expression_without_language_id
    login_as :librarian1
    put :update, :id => 1, :expression => {:language_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_expression
    login_as :librarian1
    put :update, :id => 1, :expression => { }
    assert_redirected_to expression_url(assigns(:expression))
  end
  
  def test_admin_should_update_expression
    login_as :admin
    put :update, :id => 1, :expression => { }
    assert_redirected_to expression_url(assigns(:expression))
  end
  
  def test_guest_should_not_destroy_expression
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count, Expression.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_expression
    login_as :user1
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count, Expression.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_expression
    login_as :librarian1
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Expression.count
    
    assert_redirected_to expressions_url
  end

  def test_admin_should_destroy_expression
    login_as :admin
    old_count = Expression.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Expression.count
    
    assert_redirected_to expressions_url
  end
end
