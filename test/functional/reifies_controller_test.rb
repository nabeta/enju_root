require 'test_helper'

class ReifiesControllerTest < ActionController::TestCase
  fixtures :reifies, :expressions, :works, :patrons, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:reifies)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:reifies)
  end

  def test_guest_should_get_index_with_expression_id
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:reifies)
  end

  def test_user_should_get_index
    login_as :user1
    get :index
    assert_response :success
    assert assigns(:reifies)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:reifies)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    login_as :librarian1
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_reify
    old_count = Reify.count
    post :create, :reify => { :work_id => 1, :expression_id => 1 }
    assert_equal old_count, Reify.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_reify
    old_count = Reify.count
    post :create, :reify => { :work_id => 1, :expression_id => 1 }
    assert_equal old_count, Reify.count
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_reify_without_work_id
    login_as :librarian1
    old_count = Reify.count
    post :create, :reify => { :expression_id => 1 }
    assert_equal old_count, Reify.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_reify_without_expression_id
    login_as :librarian1
    old_count = Reify.count
    post :create, :reify => { :work_id => 1 }
    assert_equal old_count, Reify.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_reify_already_created
    login_as :librarian1
    old_count = Reify.count
    post :create, :reify => { :work_id => 1, :expression_id => 1 }
    assert_equal old_count, Reify.count
    
    assert_response :success
  end

  def test_librarian_should_create_reify_not_created_yet
    login_as :librarian1
    old_count = Reify.count
    post :create, :reify => { :work_id => 1, :expression_id => 6 }
    assert_equal old_count+1, Reify.count
    
    assert_redirected_to reify_url(assigns(:reify))
  end

  def test_guest_should_show_reify
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_reify
    login_as :user1
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_reify
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1, :work_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => 1, :work_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_reify
    put :update, :id => 1, :reify => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_reify
    login_as :user1
    put :update, :id => 1, :reify => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_reify_without_work_id
    login_as :librarian1
    put :update, :id => 1, :reify => {:work_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_reify_without_expression_id
    login_as :librarian1
    put :update, :id => 1, :reify => {:expression_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_reify
    login_as :librarian1
    put :update, :id => 1, :reify => { }
    assert_redirected_to reify_url(assigns(:reify))
  end
  
  def test_librarian_should_update_reify_with_position
    login_as :librarian1
    put :update, :id => 1, :reify => { }, :expression_id => 1, :position => 1
    assert_redirected_to expression_reifies_url(assigns(:expression))
  end
  
  def test_guest_should_not_destroy_reify
    old_count = Reify.count
    delete :destroy, :id => 1
    assert_equal old_count, Reify.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_reify
    login_as :user1
    old_count = Reify.count
    delete :destroy, :id => 1
    assert_equal old_count, Reify.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_reify
    login_as :librarian1
    old_count = Reify.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Reify.count
    
    assert_redirected_to reifies_url
  end

  def test_librarian_should_destroy_reify_with_work_id
    login_as :librarian1
    old_count = Reify.count
    delete :destroy, :id => 1, :work_id => 1
    assert_equal old_count-1, Reify.count
    
    assert_redirected_to work_expressions_url(assigns(:work))
  end

end
