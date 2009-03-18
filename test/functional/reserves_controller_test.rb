require 'test_helper'

class ReservesControllerTest < ActionController::TestCase
  fixtures :reserves, :items, :manifestations, :manifestation_forms,
    :users, :user_groups, :roles, :checkout_types, :user_group_has_checkout_types, :manifestation_form_has_checkout_types, :request_status_types

  def test_guest_should_not_get_index
    get :index, :user_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_index
    login_as :user1
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:reserves)
  end

  def test_user_should_get_my_index_feed
    login_as :user1
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:reserves)
  end

  def test_user_should_not_get_other_index
    login_as :user1
    get :index, :user_id => users(:user2).login
    assert_response :forbidden
  end

  def test_librarian_should_get_index_without_user_id
    login_as :librarian1
    get :index
    assert_response :success
    assert assigns(:reserves)
  end

  def test_librarian_should_get_index_feed_without_user_id
    login_as :librarian1
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:reserves)
  end

  def test_librarian_should_get_other_index
    login_as :librarian1
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:reserves)
  end

  def test_librarian_should_get_other_index_feed
    login_as :librarian1
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:reserves)
  end

  def test_admin_should_get_other_index
    login_as :admin
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:reserves)
  end

  def test_guest_should_not_get_new
    get :new, :user_id => users(:user1).login, :manifestation_id => 3
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_my_new
    login_as :user1
    get :new, :user_id => users(:user1).login, :manifestation_id => 3
    assert_response :success
  end
  
  def test_user_should_not_get_other_new
    login_as :user1
    get :new, :user_id => users(:user2).login, :manifestation_id => 5
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new_without_user_id
    login_as :librarian1
    get :new, :manifestation_id => 3
    assert_response :success
  end
  
  def test_librarian_should_get_other_new
    login_as :librarian1
    get :new, :user_id => users(:user1).login, :manifestation_id => 3
    assert_response :success
  end
  
  def test_admin_should_get_other_new
    login_as :admin
    get :new, :user_id => users(:user1).login, :manifestation_id => 3
    assert_response :success
  end
  
  def test_guest_should_not_create_reserve
    old_count = Reserve.count
    post :create, :reserve => { }
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_reserve_without_manifestation_id
    login_as :admin
    old_count = Reserve.count
    post :create, :user_id => users(:admin).login, :reserve => {:user_number => users(:admin).user_number}
    assert_equal old_count, Reserve.count
    
    assert_response :success
  end

  def test_user_should_create_my_reserve
    login_as :user1
    old_count = Reserve.count
    post :create, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    assert_equal old_count+1, Reserve.count
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
    assert assigns(:reserve).expired_at > Time.zone.now
  end

  def test_user_should_not_create_other_reserve
    login_as :user1
    old_count = Reserve.count
    post :create, :user_id => users(:user2).login, :reserve => {:user_number => users(:user2).user_number, :manifestation_id => 6}
    assert_equal old_count, Reserve.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_reserve_without_user_id
    login_as :librarian1
    old_count = Reserve.count
    post :create, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    assert_equal old_count+1, Reserve.count
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_librarian_should_create_other_reserve
    login_as :librarian1
    old_count = Reserve.count
    post :create, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    assert_equal old_count+1, Reserve.count
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_admin_should_create_other_reserve
    login_as :admin
    old_count = Reserve.count
    post :create, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    assert_equal old_count+1, Reserve.count
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_everyone_should_not_create_reserve_over_reserve_limit
    login_as :librarian1
    old_count = Reserve.count
    post :create, :user_id => users(:admin).login, :reserve => {:user_number => users(:admin).user_number, :manifestation_id => 5}
    assert_equal old_count, Reserve.count
    assert_equal 'Excessed reservation limit.', flash[:notice]
    assert_nil assigns(:reserve).expired_at
    
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_guest_should_not_show_reserve
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_show_missing_reserve
    login_as :admin
    get :show, :id => 100, :user_id => users(:user1).login
    assert_response :missing
  end

  def test_user_should_not_show_reserve_without_user_id
    login_as :user1
    get :show, :id => 3
    assert_response :forbidden
  end

  def test_user_should_show_my_reserve
    login_as :user1
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_show_other_reserve
    login_as :user2
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :forbidden
  end

  def test_librarian_should_show_reserve_without_user_id
    login_as :librarian1
    get :show, :id => 3
    assert_response :success
  end

  def test_librarian_should_show_other_reserve
    login_as :librarian1
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_admin_should_show_other_reserve
    login_as :admin
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 3
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_missing_edit
    login_as :admin
    get :edit, :id => 1, :user_id => users(:user1).login
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    login_as :user1
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    login_as :user1
    get :edit, :id => 5, :user_id => users(:user2).login
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit_without_user_id
    login_as :librarian1
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_librarian_should_get_other_edit
    login_as :librarian1
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_admin_should_get_other_edit
    login_as :admin
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_guest_should_not_update_reserve
    put :update, :id => 1, :reserve => { }
    assert_response :redirect
  end
  
  def test_everyone_should_not_update_reserve_without_manifestation_id
    login_as :admin
    put :update, :id => 1, :user_id => users(:admin).login, :reserve => {:user_number => users(:admin).user_number, :manifestation_id => nil}
    assert_response :success
  end
  
  def test_user_should_not_update_missing_reserve
    login_as :user1
    put :update, :id => 100, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number}
    assert_response :missing
  end
  
  def test_user_should_update_my_reserve
    login_as :user1
    put :update, :id => 3, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number}
    assert_equal 'Reserve was successfully updated.', flash[:notice]
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_user_should_cancel_my_reserve
    login_as :user1
    old_message_queues_count = MessageQueue.count
    put :update, :id => 3, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_equal 'Reservation was canceled.', flash[:notice]
    assert_equal 'canceled', assigns(:reserve).state
    assert_equal old_message_queues_count + 2, MessageQueue.count
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_user_should_not_update_other_reserve
    login_as :user1
    put :update, :id => 5, :user_id => users(:user2).login, :reserve => {:user_number => users(:user2).user_number}
    assert_response :forbidden
  end
  
  def test_user_should_not_cancel_other_reserve
    login_as :user1
    put :update, :id => 5, :user_id => users(:user2).login, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_response :forbidden
  end

  def test_librarian_should_update_without_user_id
    login_as :librarian1
    put :update, :id => 3, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_librarian_should_update_other_reserve
    login_as :librarian1
    put :update, :id => 3, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_librarian_should_cancel_other_reserve
    login_as :librarian1
    old_message_queues_count = MessageQueue.count
    put :update, :id => 3, :user_id => users(:user1).login, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_equal 'Reservation was canceled.', flash[:notice]
    assert_equal 'canceled', assigns(:reserve).state
    assert_equal old_message_queues_count + 2, MessageQueue.count
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_admin_should_update_other_reserve_without_user_id
    login_as :admin
    put :update, :id => 3, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).login, assigns(:reserve))
  end

  def test_guest_should_not_destroy_reserve
    old_count = Reserve.count
    delete :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_reserve_without_user_id
    login_as :user1
    old_count = Reserve.count
    delete :destroy, :id => 1
    assert_equal old_count, Reserve.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_missing_reserve
    login_as :admin
    old_count = Reserve.count
    delete :destroy, :id => 100, :user_id => users(:user1).login
    assert_equal old_count, Reserve.count
    
    assert_response :missing
  end

  def test_user_should_destroy_my_reserve
    login_as :user1
    old_count = Reserve.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Reserve.count
    
    assert_redirected_to user_reserves_url(users(:user1).login)
  end

  def test_user_should_not_destroy_other_reserve
    login_as :user1
    old_count = Reserve.count
    delete :destroy, :id => 5, :user_id => users(:user2).login
    assert_equal old_count, Reserve.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_other_reserve
    login_as :librarian1
    old_count = Reserve.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Reserve.count
    
    assert_redirected_to user_reserves_url(users(:user1).login)
  end

  def test_user_should_destroy_other_reserve
    login_as :admin
    old_count = Reserve.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Reserve.count
    
    assert_redirected_to user_reserves_url(users(:user1).login)
  end

end
