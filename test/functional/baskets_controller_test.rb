require 'test_helper'

class BasketsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :baskets, :checked_items, :checkouts, :reserves,
    :items, :circulation_statuses, :manifestations, :carrier_types,
    :languages, :exemplifies, :users, :roles

  def test_guest_should_not_get_index
    get :index, :user_id => users(:user1).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_get_index_without_user_id
    UserSession.create users(:admin)
    get :index
    assert_response :forbidden
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index, :user_id => users(:user1).login
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index, :user_id => users(:user1).login
    assert_response :success
    assert assigns(:baskets)
  end

  def test_guest_should_not_get_new
    get :new, :user_id => users(:user1).login
    assert_response :redirect
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

  def test_guest_should_not_create_basket
    old_count = Basket.count
    post :create, :basket => { }
    assert_equal old_count, Basket.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_basket
    UserSession.create users(:user1)
    old_count = Basket.count
    post :create, :basket => {:user_number => users(:user1).user_number }
    assert_equal old_count, Basket.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_basket_without_user_number
    UserSession.create users(:librarian1)
    old_count = Basket.count
    post :create, :basket => { }
    assert_equal old_count, Basket.count
    
    assert_response :success
  end

  def test_librarian_should_create_basket
    UserSession.create users(:librarian1)
    old_count = Basket.count
    post :create, :basket => {:user_number => users(:user1).user_number }
    assert_equal old_count+1, Basket.count
    
    assert_redirected_to user_basket_checked_items_url(users(:user1).login, assigns(:basket))
  end

  def test_guest_should_not_show_basket
    get :show, :id => 1, :user_id => users(:admin).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_show_basket_without_user_number
    UserSession.create users(:admin)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_user_should_not_show_basket
    UserSession.create users(:user1)
    get :show, :id => 3, :user_id => users(:user1).login
    assert_response :forbidden
  end

  def test_librarian_should_show_basket
    UserSession.create users(:librarian1)
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
  
  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).login
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => 1, :user_id => users(:admin).login
    assert_response :success
  end
  
  def test_guest_should_not_destroy_basket
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).login
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_basket_without_user_id
    UserSession.create users(:admin)
    delete :destroy, :id => 1, :basket => { }
    assert_response :forbidden
  end

  def test_user_should_not_destroy_basket
    UserSession.create users(:user1)
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).login
    assert_response :forbidden
  end

  def test_librarian_should_destroy_basket_without_user_id
    UserSession.create users(:librarian1)
    delete :destroy, :id => 1, :basket => {:user_id => nil}, :user_id => users(:user1).login
    assert_response :redirect
    assert_redirected_to user_checkouts_url(assigns(:basket).user.login)
  end

  def test_librarian_should_destroy_basket
    UserSession.create users(:librarian1)
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).login
    assert_redirected_to user_checkouts_url(assigns(:basket).user.login)
  end

  def test_guest_should_not_destroy_basket
    old_count = Basket.count
    delete :destroy, :id => 1, :user_id => users(:admin).login
    assert_equal old_count, Basket.count
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_basket_without_user_id
    UserSession.create users(:admin)
    old_count = Basket.count
    delete :destroy, :id => 1
    assert_equal old_count, Basket.count
    
    assert_response :forbidden
  end
  
  def test_user_should_not_destroy_basket
    UserSession.create users(:user1)
    old_count = Basket.count
    delete :destroy, :id => 3, :user_id => users(:user1).login
    assert_equal old_count, Basket.count
    
    assert_response :forbidden
  end
  
  def test_librarian_should_update_basket_when_not_checked_out
    UserSession.create users(:librarian1)
    put :update, :id => 8, :user_id => users(:user1).login
    assert_equal 'On Loan', assigns(:basket).checkouts.first.item.circulation_status.name
    
    assert_redirected_to user_checkouts_url(assigns(:user).login)
  end

  #def test_system_should_show_notice_when_patron_reserved_checkout_items
  #  UserSession.create users(:librarian1)
  #  put :update, :id => 8, :user_id => users(:user1).login
  #  assert_equal 'This item is reserved by this patron. Reservation completed.', flash[:reserved]
  #  assert_nil flash[:notice]
    
  #  assert_redirected_to user_basket_checked_items_url(assigns(:user).login, assigns(:basket))
  #end

  #def test_system_should_show_notice_when_other_patron_reserved
  #  UserSession.create users(:librarian1)
  #  old_count = Basket.count
  #  put :update, :id => 2, :user_id => users(:librarian1).login
  #  #assert_equal 'Reserved item included!', flash[:reserved]
  #  assert_equal old_count, Basket.count
  #  
  #  assert_redirected_to user_basket_checked_items_url(assigns(:user).login, assigns(:basket))
  #end

end
