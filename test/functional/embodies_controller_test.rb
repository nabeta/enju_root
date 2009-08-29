require 'test_helper'

class EmbodiesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :embodies, :expressions, :manifestations, :expression_forms, :carrier_types, :languages, :frequencies,
    :works, :form_of_works, :patrons, :users, :realizes, :produces

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:embodies)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:embodies)
  end

  def test_guest_should_get_index_with_expression_id
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:expression)
    assert assigns(:embodies)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:embodies)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:embodies)
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
  
  def test_guest_should_not_create_embody
    old_count = Embody.count
    post :create, :embody => { :expression_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Embody.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_embody
    old_count = Embody.count
    post :create, :embody => { :expression_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Embody.count
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_embody_without_expression_id
    UserSession.create users(:librarian1)
    old_count = Embody.count
    post :create, :embody => { :manifestation_id => 1 }
    assert_equal old_count, Embody.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_embody_without_manifestation_id
    UserSession.create users(:librarian1)
    old_count = Embody.count
    post :create, :embody => { :expression_id => 1 }
    assert_equal old_count, Embody.count
    
    assert_response :success
  end

  def test_librarian_should_not_create_embody_already_created
    UserSession.create users(:librarian1)
    old_count = Embody.count
    post :create, :embody => { :expression_id => 1, :manifestation_id => 1 }
    assert_equal old_count, Embody.count
    
    assert_response :success
  end

  def test_librarian_should_create_embody_not_created_yet
    UserSession.create users(:librarian1)
    old_count = Embody.count
    post :create, :embody => { :expression_id => 1, :manifestation_id => 10 }
    assert_equal old_count+1, Embody.count
    
    assert_redirected_to embody_url(assigns(:embody))
  end

  def test_guest_should_show_embody
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_embody
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_embody
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
  
  def test_guest_should_not_update_embody
    put :update, :id => 1, :embody => {:expression_id => 1, :manifestation_id => 1 }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_embody
    UserSession.create users(:user1)
    put :update, :id => 1, :embody => {:expression_id => 1, :manifestation_id => 1 }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_embody_without_expression_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :embody => {:expression_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_embody_without_manifestation_id
    UserSession.create users(:librarian1)
    put :update, :id => 1, :embody => {:manifestation_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_embody
    UserSession.create users(:librarian1)
    put :update, :id => 1, :embody => {:expression_id => 1, :manifestation_id => 5}
    assert_redirected_to embody_url(assigns(:embody))
  end
  
  def test_guest_should_not_destroy_embody
    old_count = Embody.count
    delete :destroy, :id => 1
    assert_equal old_count, Embody.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_embody
    UserSession.create users(:user1)
    old_count = Embody.count
    delete :destroy, :id => 1
    assert_equal old_count, Embody.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_embody
    UserSession.create users(:librarian1)
    old_count = Embody.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Embody.count
    
    assert_redirected_to embodies_url
  end
end
