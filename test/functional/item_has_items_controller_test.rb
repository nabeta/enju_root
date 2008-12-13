require 'test_helper'

class ItemHasItemsControllerTest < ActionController::TestCase
  fixtures :item_has_items

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_has_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item_has_item" do
    assert_difference('ItemHasItem.count') do
      post :create, :item_has_item => { }
    end

    assert_redirected_to item_has_item_path(assigns(:item_has_item))
  end

  test "should show item_has_item" do
    get :show, :id => item_has_items(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => item_has_items(:one).id
    assert_response :success
  end

  test "should update item_has_item" do
    put :update, :id => item_has_items(:one).id, :item_has_item => { }
    assert_redirected_to item_has_item_path(assigns(:item_has_item))
  end

  test "should destroy item_has_item" do
    assert_difference('ItemHasItem.count', -1) do
      delete :destroy, :id => item_has_items(:one).id
    end

    assert_redirected_to item_has_items_path
  end
end
