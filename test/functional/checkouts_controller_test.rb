require 'test_helper'

class CheckoutsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :checkouts, :users, :patrons, :roles, :user_groups, :reserves, :baskets, :library_groups, :checkout_types, :patron_types,
    :user_group_has_checkout_types, :carrier_type_has_checkout_types,
    :manifestations, :carrier_types,
    :items, :circulation_statuses, :exemplifies

  def test_guest_should_not_get_index
    get :index, :user_id => users(:admin).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_get_index_without_user_id
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_user_should_get_my_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_user_should_get_my_index_feed
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login, :format => 'rss'
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_guest_should_get_ics
    # icsファイルは誰でもアクセスできるので、URLを他人に公開してはならない
    get :index, :icalendar_token => users(:user1).checkout_icalendar_token
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_user_should_not_get_other_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:admin).login
    assert_response :forbidden
  end

  def test_user_should_not_get_overdue_index
    UserSession.create users(:user1)
    get :index, :view => 'overdue'
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
  end

  def test_librarian_should_get_index_csv
    UserSession.create users(:librarian1)
    get :index, :format => 'csv'
    assert_response :success
  end

  def test_librarian_should_get_index_rss
    UserSession.create users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
  end

  def test_librarian_should_get_other_index
    UserSession.create users(:librarian1)
    get :index, :user_id => users(:admin).login
    assert_response :success
  end

  def test_librarian_should_get_overdue_index
    UserSession.create users(:librarian1)
    get :index, :view => 'overdue'
    assert_response :success
  end

  def test_librarian_should_get_overdue_index_with_number_of_days_overdue
    UserSession.create users(:librarian1)
    get :index, :view => 'overdue', :days_overdue => 2
    assert_response :success
    assert assigns(:checkouts).size > 0
  end

  def test_librarian_should_get_overdue_index_with_invalid_number_of_days
    UserSession.create users(:librarian1)
    get :index, :view => 'overdue', :days_overdue => 'invalid days'
    assert_response :success
    assert assigns(:checkouts).size > 0
  end

  def test_admin_should_get_other_index
    UserSession.create users(:admin)
    get :index, :user_id => users(:user1).login
    assert_response :success
  end

  def test_guest_should_not_get_new
    get :new, :user_id => users(:admin).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_new_without_user_id
    UserSession.create users(:admin)
    get :new
    assert_response :forbidden
  end
  
  def test_user_should_not_get_my_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:user1).login
    assert_response :forbidden
  end
  
  def test_user_should_not_get_other_new
    UserSession.create users(:user1)
    get :new, :user_id => users(:admin).login
    assert_response :forbidden
  end
  
  def test_librarian_should_get_other_new
    UserSession.create users(:librarian1)
    get :new, :user_id => users(:admin).login
    assert_response :forbidden
  end
  
  def test_admin_should_not_get_other_new
    UserSession.create users(:admin)
    get :new, :user_id => users(:user1).login
    assert_response :forbidden
  end
  
  def test_guest_should_not_create_checkout
    old_count = Checkout.count
    post :create, :user_id => users(:admin).login, :checkout => {:item_id => 6}
    assert_nil flash[:notice]
    assert_equal old_count, Checkout.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_my_checkout
    UserSession.create users(:user1)
    old_count = Checkout.count
    post :create, :user_id => users(:user1).login, :checkout => {:item_id => 6}
    assert_equal old_count, Checkout.count
    
    #assert_redirected_to checkout_url(assigns(:checkout))
    assert_response :forbidden
  end

  def test_user_should_not_create_other_checkout
    UserSession.create users(:user1)
    old_count = Checkout.count
    post :create, :user_id => users(:admin).login, :checkout => {:item_id => 6}
    assert_equal old_count, Checkout.count
    
    #assert_redirected_to checkout_url(assigns(:checkout))
    assert_response :forbidden
  end

  def test_librarian_should_not_create_checkout
    # 直接追加はできない。Basket経由のみ
    UserSession.create users(:librarian1)
    old_count = Checkout.count
    post :create, :user_id => users(:user1).login, :checkout => {:item_id => 6}
    assert_equal old_count, Checkout.count
    
    assert_response :forbidden
    #assert_redirected_to user_checkouts_url(assigns(:user))
  end

  def test_admin_should_not_create_checkout
    # 直接追加はできない。Basket経由のみ
    UserSession.create users(:admin)
    old_count = Checkout.count
    post :create, :user_id => users(:user1).login, :checkout => {:item_id => 6}
    assert_equal old_count, Checkout.count
    
    assert_response :forbidden
    #assert_redirected_to user_checkouts_url(assigns(:user))
  end

  def test_guest_should_not_show_checkout_without_login
    get :show, :id => 1, :user_id => users(:admin).login
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_missing_checkout
    UserSession.create users(:user1)
    get :show, :id => 100, :user_id => users(:user1).login
    assert_response :missing
  end

  def test_user_should_show_my_checkout
    UserSession.create users(:user1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_user_should_not_show_other_checkout
    UserSession.create users(:user1)
    get :show, :id => 1, :user_id => users(:admin).login
    assert_response :forbidden
  end

  def test_librarian_should_show_other_checkout
    UserSession.create users(:librarian1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_admin_should_show_other_checkout
    UserSession.create users(:admin)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1, :user_id => users(:admin).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_edit_without_user_id
    UserSession.create users(:admin)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_my_edit
    UserSession.create users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    UserSession.create users(:user1)
    get :edit, :id => 1, :user_id => users(:admin).login
    assert_response :forbidden
  end
  
  def test_librarian_should_get_other_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_admin_should_get_other_edit
    UserSession.create users(:admin)
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :success
  end
  
  def test_guest_should_not_update_checkout
    put :update, :id => 1, :user_id => users(:admin).login, :checkout => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_update_checkout_without_user_id
    UserSession.create users(:admin)
    put :update, :id => 1, :checkout => { }
    assert_response :forbidden
  end
  
  def test_everyone_should_not_update_missing_checkout
    UserSession.create users(:admin)
    put :update, :id => 100, :user_id => users(:admin).login, :checkout => { }
    assert_response :missing
  end
  
  def test_user_should_update_my_checkout
    UserSession.create users(:user1)
    put :update, :id => 3, :user_id => users(:user1).login, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user.login, assigns(:checkout))
  end
  
  def test_user_should_not_update_checkout_without_item_id
    UserSession.create users(:user1)
    put :update, :id => 3, :user_id => users(:user1).login, :checkout => {:item_id => nil}
    assert_response :success
  end
  
  def test_user_should_not_update_other_checkout
    UserSession.create users(:user1)
    put :update, :id => 1, :user_id => users(:admin).login, :checkout => { }
    assert_response :forbidden
  end
  
  def test_user_should_not_update_already_renewed_checkout
    UserSession.create users(:user1)
    put :update, :id => 9, :user_id => users(:user1).login, :checkout => { }
    assert_equal 'Excessed checkout renewal limit.', flash[:notice]
    assert_response :redirect
    assert_redirected_to edit_user_checkout_url(assigns(:checkout).user.login, assigns(:checkout))
  end
  
  def test_librarian_should_update_checkout_item_is_reserved
    UserSession.create users(:librarian1)
    put :update, :id => 8, :user_id => users(:librarian1).login, :checkout => { }
    assert_equal 'This item is reserved.', flash[:notice]
    assert_response :redirect
    assert_redirected_to edit_user_checkout_url(assigns(:checkout).user.login, assigns(:checkout))
  end
  
  def test_librarian_should_update_other_checkout
    UserSession.create users(:librarian1)
    put :update, :id => 1, :user_id => users(:admin).login, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user.login, assigns(:checkout))
  end
  
  def test_admin_should_update_other_checkout
    UserSession.create users(:admin)
    put :update, :id => 3, :user_id => users(:user1).login, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user.login, assigns(:checkout))
  end
  
  def test_guest_should_not_destroy_checkout
    old_count = Checkout.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count, Checkout.count
    
    assert_redirected_to new_user_session_url 
  end

  def test_everyone_should_not_destroy_checkout_without_user_id
    UserSession.create users(:admin)
    old_count = Checkout.count
    delete :destroy, :id => 3
    assert_equal old_count, Checkout.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_missing_checkout
    UserSession.create users(:admin)
    old_count = Checkout.count
    delete :destroy, :id => 100, :user_id => users(:admin).login
    assert_equal old_count, Checkout.count
    
    assert_response :missing
  end

  def test_user_should_destroy_my_checkout
    UserSession.create users(:user1)
    old_count = Checkout.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Checkout.count
    
    assert_redirected_to user_checkouts_url(users(:user1).login)
  end
  
  def test_librarian_should_destroy_other_checkout
    UserSession.create users(:librarian1)
    old_count = Checkout.count
    delete :destroy, :id => 1, :user_id => users(:admin).login
    assert_equal old_count-1, Checkout.count
    
    #assert_response :forbidden
    assert_redirected_to user_checkouts_url(users(:admin).login)
  end

  def test_admin_should_destroy_other_checkout
    UserSession.create users(:admin)
    old_count = Checkout.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count-1, Checkout.count
    
    #assert_response :forbidden
    assert_redirected_to user_checkouts_url(users(:user1).login)
  end

end
