require 'test_helper'

class FrequenciesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :frequencies, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:frequencies)
  end

  def test_librarian_should_not_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:frequencies)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:frequencies)
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
  
  def test_guest_should_not_create_frequency
    old_count = Frequency.count
    post :create, :frequency => { }
    assert_equal old_count, Frequency.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_frequency
    UserSession.create users(:user1)
    old_count = Frequency.count
    post :create, :frequency => { }
    assert_equal old_count, Frequency.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_frequency
    UserSession.create users(:librarian1)
    old_count = Frequency.count
    post :create, :frequency => { }
    assert_equal old_count, Frequency.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_frequency_without_name
    UserSession.create users(:admin)
    old_count = Frequency.count
    post :create, :frequency => { }
    assert_equal old_count, Frequency.count
    
    assert_response :success
  end

  def test_admin_should_create_frequency
    UserSession.create users(:admin)
    old_count = Frequency.count
    post :create, :frequency => {:name => 'test'}
    assert_equal old_count+1, Frequency.count
    
    assert_redirected_to frequency_url(assigns(:frequency))
  end

  def test_guest_should_show_frequencies
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_frequencies
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_frequencies
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_frequencies
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
  
  def test_guest_should_not_update_frequency
    put :update, :id => 1, :frequency => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_frequency
    UserSession.create users(:user1)
    put :update, :id => 1, :frequency => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_frequency
    UserSession.create users(:librarian1)
    put :update, :id => 1, :frequency => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_frequency_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :frequency => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_frequency
    UserSession.create users(:admin)
    put :update, :id => 1, :frequency => { }
    assert_redirected_to frequency_url(assigns(:frequency))
  end
  
  def test_guest_should_not_destroy_frequencies
    old_count = Frequency.count
    delete :destroy, :id => 1
    assert_equal old_count, Frequency.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_frequencies
    UserSession.create users(:user1)
    old_count = Frequency.count
    delete :destroy, :id => 1
    assert_equal old_count, Frequency.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_frequencies
    UserSession.create users(:librarian1)
    old_count = Frequency.count
    delete :destroy, :id => 1
    assert_equal old_count, Frequency.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_frequencies
    UserSession.create users(:admin)
    old_count = Frequency.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Frequency.count
    
    assert_redirected_to frequencies_url
  end
end
