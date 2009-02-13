require 'test_helper'

class CheckinsControllerTest < ActionController::TestCase
  fixtures :checkins, :checkouts, :users, :patrons, :roles, :roles_users, :user_groups, :reserves, :baskets, :library_groups, :checkout_types, :patron_types,
    :user_group_has_checkout_types, :manifestation_form_has_checkout_types,
    :manifestations, :manifestation_forms,
    :items, :circulation_statuses, :exemplifies,
    :shelves, :request_status_types,
    :expressions, :expression_forms, :languages, :message_templates,
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
    assert_response :redirect
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
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
    assert_response :redirect
    assert_redirected_to checkins_url
  end
  
  def test_guest_should_not_create_checkin
    old_count = Checkin.count
    post :create, :checkin => {:item_id => 3}, :basket => 9
    assert_equal old_count, Checkin.count
    
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_create_checkin_without_item_id
    login_as :admin
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => nil}, :basket_id => 9
    assert_equal old_count, Checkin.count
    
    assert_response :redirect
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
    #assert_response :success
  end

  def test_user_should_not_create_checkin
    login_as :user1
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => '00003'}, :basket_id => 9
    assert_equal old_count, Checkin.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_checkin
    login_as :librarian1
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => '00003'}, :basket_id => 9
    assert_equal old_count+1, Checkin.count
    
    assert_equal 'Available On Shelf', assigns(:checkin).item.circulation_status.name
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
  end

  def test_system_should_show_message_when_item_includes_supplements
    login_as :librarian1
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => '00004'}, :basket_id => 9
    assert_equal old_count+1, Checkin.count
    
    assert_equal 'Available On Shelf', assigns(:checkin).item.circulation_status.name
    assert flash[:message].index('This item includes supplements.')
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
  end

  def test_system_should_show_notice_when_other_library_item
    login_as :librarian2
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => '00009'}, :basket_id => 9
    assert_equal old_count+1, Checkin.count
    assert flash[:message].index('This item is other library\'s resource!')
    
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
  end

  def test_system_should_show_notice_when_reserved
    login_as :librarian1
    old_count = Checkin.count
    post :create, :checkin => {:item_identifier => '00008'}, :basket_id => 9
    assert_equal old_count+1, Checkin.count
    assert flash[:message].index('This item is reserved!')
    assert_equal 'retained', assigns(:checkin).item.next_reservation.state
    
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.login, assigns(:basket))
  end

  def test_guest_should_not_show_checkin
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_show_missing_checkin
    login_as :admin
    get :show, :id => 100
    assert_response :missing
  end

  def test_user_should_not_show_checkin
    login_as :user1
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_checkin
    login_as :librarian1
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_session_url
  end
  
  def test_everyone_should_not_get_missing_edit
    login_as :admin
    get :edit, :id => 100
    assert_response :missing
  end
  
  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_checkin
    put :update, :id => 1, :checkin => { :item_identifier => 1 }
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_update_missing_checkin
    login_as :admin
    put :update, :id => 100, :checkin => { }
    assert_response :missing
  end

  def test_everyone_should_not_update_checkin_without_item_identifier
    login_as :admin
    put :update, :id => 1, :checkin => {:item_identifier => nil}
    assert_response :success
  end

  def test_user_should_not_update_checkin
    login_as :user1
    put :update, :id => 1, :checkin => { :item_identifier => '00001' }
    assert_response :forbidden
  end

  def test_librarian_should_update_checkin
    login_as :librarian1
    put :update, :id => 1, :checkin => { :item_identifier => '00001' }
    assert_redirected_to checkin_url(assigns(:checkin))
  end

  def test_guest_should_not_destroy_checkin
    old_count = Checkin.count
    delete :destroy, :id => 1
    assert_equal old_count, Checkin.count
    
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_everyone_should_not_destroy_missing_checkin
    login_as :admin
    old_count = Checkin.count
    delete :destroy, :id => 100
    assert_equal old_count, Checkin.count
    
    assert_response :missing
  end
  
  def test_user_should_not_destroy_checkin
    login_as :user1
    old_count = Checkin.count
    delete :destroy, :id => 1
    assert_equal old_count, Checkin.count
    
    assert_response :forbidden
  end
  
  def test_librarian_should_destroy_checkin
    login_as :librarian1
    old_count = Checkin.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Checkin.count
    
    assert_redirected_to checkins_url
  end
end
