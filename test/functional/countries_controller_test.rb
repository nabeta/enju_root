require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :countries, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_user_should_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_admin_should_get_index
    UserSession.create users(:admin)
    get :index
    assert_response :success
    assert assigns(:countries)
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
  
  def test_guest_should_not_create_country
    old_count = Country.count
    post :create, :country => { }
    assert_equal old_count, Country.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_country
    UserSession.create users(:user1)
    old_count = Country.count
    post :create, :country => { }
    assert_equal old_count, Country.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_country
    UserSession.create users(:librarian1)
    old_count = Country.count
    post :create, :country => { }
    assert_equal old_count, Country.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_country_without_name
    UserSession.create users(:admin)
    old_count = Country.count
    post :create, :country => { }
    assert_equal old_count, Country.count
    
    assert_response :success
  end

  def test_admin_should_create_country
    UserSession.create users(:admin)
    old_count = Country.count
    post :create, :country => {:name => 'test', :alpha_2 => '000', :alpha_3 => '000', :numeric_3 => '000'}
    assert_equal old_count+1, Country.count
    
    assert_redirected_to country_url(assigns(:country))
  end

  def test_guest_should_show_country
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_country
    UserSession.create users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_country
    UserSession.create users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_country
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
  
  def test_guest_should_not_update_country
    put :update, :id => 1, :country => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_country
    UserSession.create users(:user1)
    put :update, :id => 1, :country => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_country
    UserSession.create users(:librarian1)
    put :update, :id => 1, :country => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_country_without_name
    UserSession.create users(:admin)
    put :update, :id => 1, :country => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_country
    UserSession.create users(:admin)
    put :update, :id => 1, :country => {:name => 'test', :alpha_2 => '000', :alpha_3 => '000', :numeric_3 => '000'}
    assert_redirected_to country_url(assigns(:country))
  end
  
  def test_guest_should_not_destroy_country
    old_count = Country.count
    delete :destroy, :id => 1
    assert_equal old_count, Country.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_country
    UserSession.create users(:user1)
    old_count = Country.count
    delete :destroy, :id => 1
    assert_equal old_count, Country.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_country
    UserSession.create users(:librarian1)
    old_count = Country.count
    delete :destroy, :id => 1
    assert_equal old_count, Country.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_country
    UserSession.create users(:admin)
    old_count = Country.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Country.count
    
    assert_redirected_to countries_url
  end
end
