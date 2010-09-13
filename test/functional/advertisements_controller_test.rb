require 'test_helper'

class AdvertisementsControllerTest < ActionController::TestCase
  fixtures :advertisements, :users, :user_groups, :advertises, :patrons, :patron_types, :roles, :library_groups, :libraries, :countries, :languages

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end
 
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_advertisement
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_advertisement
    sign_in users(:user1)
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_advertisement
    sign_in users(:librarian1)
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_advertisement_without_title
    sign_in users(:admin)
    old_count = Advertisement.count
    post :create, :advertisement => { }
    assert_equal old_count, Advertisement.count
    
    assert_response :success
  end

  def test_admin_should_not_create_advertisement_with_invalid_dates
    sign_in users(:admin)
    old_count = Advertisement.count
    post :create, :advertisement => {:title => 'test', :body => 'test', :url => 'http://kamata.lib.teu.ac.jp/', :started_at => Time.zone.now, :ended_at => 1.day.ago }
    assert_equal old_count, Advertisement.count
    
    assert_response :success
  end

  def test_admin_should_create_advertisement
    sign_in users(:admin)
    old_count = Advertisement.count
    post :create, :advertisement => {:title => 'test', :body => 'test', :url => 'http://kamata.lib.teu.ac.jp/', :started_at => Date.today, :ended_at => Date.tomorrow }
    assert_equal old_count+1, Advertisement.count
    
    assert_redirected_to advertisement_url(assigns(:advertisement))
  end

  def test_guest_should_not_show_advertisement
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_advertisement
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_not_show_advertisement
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_advertisement
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_advertisement
    put :update, :id => 1, :advertisement => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_advertisement
    sign_in users(:user1)
    put :update, :id => 1, :advertisement => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_advertisement
    sign_in users(:librarian1)
    put :update, :id => 1, :advertisement => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_advertisement_without_title
    sign_in users(:admin)
    put :update, :id => 1, :advertisement => {:title => ""}
    assert_response :success
  end
  
  def test_admin_should_update_advertisement
    sign_in users(:admin)
    put :update, :id => 1, :advertisement => { }
    assert_redirected_to advertisement_url(assigns(:advertisement))
  end
  
  def test_guest_should_not_destroy_advertisement
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_advertisement
    sign_in users(:user1)
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_advertisement
    sign_in users(:librarian1)
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count, Advertisement.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_advertisement
    sign_in users(:admin)
    old_count = Advertisement.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Advertisement.count
    
    assert_redirected_to advertisements_url
  end
end
