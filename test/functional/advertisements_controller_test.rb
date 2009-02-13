require 'test_helper'

class AdvertisementsControllerTest < ActionController::TestCase
  fixtures :advertisements, :users, :user_groups, :advertises, :patrons, :patron_types, :roles, :roles_users, :library_groups, :libraries, :countries, :languages,
    :people, :corporate_bodies, :families

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    login_as :admin
    get :index
    assert_response :success
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
  
  def test_librarian_should_not_get_new
    login_as :librarian1
    get :new
    assert_response :forbidden
  end
 
  def test_admin_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_advertisement
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_advertisement
    login_as :user1
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_advertisement
    login_as :librarian1
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_advertisement_without_title
    login_as :admin
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :success
  end

  def test_admin_should_not_create_advertisement_with_invalid_dates
    login_as :admin
    old_count = Advertisement.count
    post :create, :advertisement => {:title => 'test', :body => 'test', :url => 'http://kamata.lib.teu.ac.jp/', :started_at => Date.tomorrow, :ended_at => Date.today }
    assert_equal old_count, Advertisement.count
    
    assert_response :success
  end

  def test_admin_should_create_advertisement
    login_as :admin
    old_count = Advertisement.count
    post :create, :advertisement => {:title => 'test', :body => 'test', :url => 'http://kamata.lib.teu.ac.jp/', :started_at => Date.today, :ended_at => Date.tomorrow }
    assert_equal old_count+1, Advertisement.count
    
    assert_redirected_to advertisement_url(assigns(:advertisement))
  end

  def test_guest_should_not_show_advertisement
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_advertisement
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_not_show_advertisement
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_advertisement
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    login_as :librarian1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_advertisement
    put :update, :id => 1, :advertisement => { }
    assert_redirected_to new_session_url
  end
  
  def test_user_should_not_update_advertisement
    login_as :user1
    put :update, :id => 1, :advertisement => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_advertisement
    login_as :librarian1
    put :update, :id => 1, :advertisement => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_advertisement_without_title
    login_as :admin
    put :update, :id => 1, :advertisement => {:title => ""}
    assert_response :success
  end
  
  def test_admin_should_update_advertisement
    login_as :admin
    put :update, :id => 1, :advertisement => { }
    assert_redirected_to advertisement_url(assigns(:advertisement))
  end
  
  def test_guest_should_not_destroy_advertisement
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_advertisement
    login_as :user1
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_advertisement
    login_as :librarian1
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_advertisement
    login_as :admin
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Advertisement.count
    
    assert_redirected_to advertisements_url
  end
end
