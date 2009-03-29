require 'test_helper'

class ProducesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :produces, :manifestations, :patrons, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:produces)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:produces)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:produces)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:produces)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:produces)
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
    assert_response :success
  end
  
  def test_guest_should_not_create_produce
    old_count = Produce.count
    post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Produce.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_produce
    old_count = Produce.count
    post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Produce.count
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_produce_already_created
    UserSession.create users(:librarian1)
    old_count = Produce.count
    post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Produce.count
    
    assert_response :success
  end

  def test_librarian_should_create_produce_not_created_yet
    UserSession.create users(:librarian1)
    old_count = Produce.count
    post :create, :produce => { :patron_id => 1, :manifestation_id => 10 }
    assert_equal old_count+1, Produce.count
    
    assert_redirected_to produce_url(assigns(:produce))
  end

  def test_guest_should_show_produce
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_produce
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_produce
    UserSession.create users(:librarian1)
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
    get :edit, :id => 1, :patron_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1, :patron_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_produce
    put :update, :id => 1, :produce => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_produce
    UserSession.create users(:user1)
    put :update, :id => 1, :produce => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_produce_without_patron_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :produce => {:patron_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_produce_without_manifestation_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :produce => {:manifestation_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_produce
    UserSession.create users(:librarian1)
    put :update, :id => 1, :produce => { }
    assert_redirected_to produce_url(assigns(:produce))
  end
  
  def test_guest_should_not_destroy_produce
    old_count = Produce.count
    delete :destroy, :id => 1
    assert_equal old_count, Produce.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_produce
    UserSession.create users(:user1)
    old_count = Produce.count
    delete :destroy, :id => 1
    assert_equal old_count, Produce.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_produce
    UserSession.create users(:librarian1)
    old_count = Produce.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Produce.count
    
    assert_redirected_to produces_url
  end
end
