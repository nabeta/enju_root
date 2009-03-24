require 'test_helper'

class ShelvesControllerTest < ActionController::TestCase
  fixtures :shelves, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_guest_should_get_index_with_library_id
    get :index, :library_id => 'kamata'
    assert_response :success
    assert assigns(:shelves)
  end

  def test_guest_should_get_index_select
    get :index, :select => true
    assert_response :success
    assert assigns(:shelves)
  end

  def test_user_should_get_index
    set_session_for users(:user1)
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_librarian_should_get_index
    set_session_for users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_admin_should_get_index
    set_session_for users(:admin)
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    set_session_for users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    set_session_for users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    set_session_for users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_shelf
    old_count = Shelf.count
    post :create, :shelf => { :name => 'My shelf', :library_id => 2 }
    assert_equal old_count, Shelf.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_shelf
    set_session_for users(:user1)
    old_count = Shelf.count
    post :create, :shelf => { :name => 'My shelf', :library_id => 2 }
    assert_equal old_count, Shelf.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_shelf
    set_session_for users(:librarian1)
    old_count = Shelf.count
    post :create, :shelf => { :name => 'My shelf', :library_id => 2 }
    assert_equal old_count, Shelf.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_shelf_without_name
    set_session_for users(:admin)
    old_count = Shelf.count
    post :create, :shelf => { :name => nil, :library_id => 2 }
    assert_equal old_count, Shelf.count
    
    assert_response :success
  end

  def test_admin_should_create_shelf
    set_session_for users(:admin)
    old_count = Shelf.count
    post :create, :shelf => { :name => 'My shelf', :library_id => 2 }
    assert_equal old_count+1, Shelf.count
    
    assert_redirected_to shelf_url(assigns(:shelf))
  end

  def test_guest_should_show_shelf
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_shelf
    set_session_for users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_shelf
    set_session_for users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_shelf
    set_session_for users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    set_session_for users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    set_session_for users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    set_session_for users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_shelf
    put :update, :id => 1, :shelf => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_shelf
    set_session_for users(:user1)
    put :update, :id => 1, :shelf => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_shelf
    set_session_for users(:librarian1)
    put :update, :id => 1, :shelf => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_shelf_without_name
    set_session_for users(:admin)
    put :update, :id => 1, :shelf => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_shelf
    set_session_for users(:admin)
    put :update, :id => 1, :shelf => { }
    assert_redirected_to library_shelf_url(assigns(:shelf).library.short_name, assigns(:shelf))
  end
  
  def test_guest_should_not_destroy_shelf
    old_count = Shelf.count
    delete :destroy, :id => 2
    assert_equal old_count, Shelf.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_shelf
    set_session_for users(:user1)
    old_count = Shelf.count
    delete :destroy, :id => 2
    assert_equal old_count, Shelf.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_shelf
    set_session_for users(:librarian1)
    old_count = Shelf.count
    delete :destroy, :id => 2
    assert_equal old_count, Shelf.count
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_shelf_id_1
    set_session_for users(:admin)
    old_count = Shelf.count
    delete :destroy, :id => 1
    assert_equal old_count, Shelf.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_shelf
    set_session_for users(:admin)
    old_count = Shelf.count
    delete :destroy, :id => 2
    assert_equal old_count-1, Shelf.count
    
    assert_redirected_to library_shelves_url(assigns(:shelf).library.short_name)
  end
end
