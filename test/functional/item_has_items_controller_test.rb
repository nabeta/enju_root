require 'test_helper'

class ItemHasItemsControllerTest < ActionController::TestCase
  fixtures :item_has_items, :items, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_has_items)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    login_as :user1
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    login_as :librarian1
    get :new
    assert_response :success
  end

  test "guest should not create item_has_item" do
    assert_no_difference('ItemHasItem.count') do
      post :create, :item_has_item => {:from_item_id => 1, :to_item_id => 2}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create item_has_item" do
    login_as :user1
    assert_no_difference('ItemHasItem.count') do
      post :create, :item_has_item => {:from_item_id => 1, :to_item_id => 2}
    end

    assert_response :forbidden
  end

  test "librarian should create item_has_item" do
    login_as :librarian1
    assert_difference('ItemHasItem.count') do
      post :create, :item_has_item => {:from_item_id => 1, :to_item_id => 2}
    end

    assert_redirected_to item_has_item_path(assigns(:item_has_item))
  end

  test "should show item_has_item" do
    get :show, :id => item_has_items(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => item_has_items(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    login_as :user1
    get :edit, :id => item_has_items(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    login_as :librarian1
    get :edit, :id => item_has_items(:one).id
    assert_response :success
  end

  test "guest should not update item_has_item" do
    put :update, :id => item_has_items(:one).id, :item_has_item => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update item_has_item" do
    login_as :user1
    put :update, :id => item_has_items(:one).id, :item_has_item => { }
    assert_response :forbidden
  end

  test "librarian should update item_has_item" do
    login_as :librarian1
    put :update, :id => item_has_items(:one).id, :item_has_item => { }
    assert_redirected_to item_has_item_path(assigns(:item_has_item))
  end

  test "guest should not destroy item_has_item" do
    assert_no_difference('ItemHasItem.count') do
      delete :destroy, :id => item_has_items(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy item_has_item" do
    login_as :user1
    assert_no_difference('ItemHasItem.count') do
      delete :destroy, :id => item_has_items(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy item_has_item" do
    login_as :librarian1
    assert_difference('ItemHasItem.count', -1) do
      delete :destroy, :id => item_has_items(:one).id
    end

    assert_redirected_to item_has_items_path
  end
end
