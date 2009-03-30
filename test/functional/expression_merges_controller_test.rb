require 'test_helper'

class ExpressionMergesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :expression_merges, :expressions, :expression_merge_lists, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:expression_merges)
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:expression_merges)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_merges)
  end

  def test_librarian_should_get_index_with_expression_id
    UserSession.create users(:librarian1)
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:expression)
    assert_not_nil assigns(:expression_merges)
  end

  def test_librarian_should_get_index_with_expression_merge_list_id
    UserSession.create users(:librarian1)
    get :index, :expression_merge_list_id => 1
    assert_response :success
    assert assigns(:expression_merge_list)
    assert_not_nil assigns(:expression_merges)
  end

  def test_guest_should_not_get_new
    get :new
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

  def test_guest_should_not_create_expression_merge
    assert_no_difference('ExpressionMerge.count') do
      post :create, :expression_merge => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_expression_merge
    UserSession.create users(:user1)
    assert_no_difference('ExpressionMerge.count') do
      post :create, :expression_merge => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_expression_merge_without_expression_id
    UserSession.create users(:librarian1)
    assert_no_difference('ExpressionMerge.count') do
      post :create, :expression_merge => {:expression_merge_list_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_expression_merge_without_expression_merge_list_id
    UserSession.create users(:librarian1)
    assert_no_difference('ExpressionMerge.count') do
      post :create, :expression_merge => {:expression_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_expression_merge
    UserSession.create users(:librarian1)
    assert_difference('ExpressionMerge.count') do
      post :create, :expression_merge => {:expression_id => 1, :expression_merge_list_id => 1}
    end

    assert_redirected_to expression_merge_url(assigns(:expression_merge))
  end

  def test_guest_should_not_show_expression_merge
    get :show, :id => expression_merges(:expression_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_expression_merge
    UserSession.create users(:user1)
    get :show, :id => expression_merges(:expression_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_expression_merge
    UserSession.create users(:librarian1)
    get :show, :id => expression_merges(:expression_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => expression_merges(:expression_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => expression_merges(:expression_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => expression_merges(:expression_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_expression_merge
    put :update, :id => expression_merges(:expression_merge_00001).id, :expression_merge => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_expression_merge
    UserSession.create users(:user1)
    put :update, :id => expression_merges(:expression_merge_00001).id, :expression_merge => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_expression_merge_without_expression_id
    UserSession.create users(:librarian1)
    put :update, :id => expression_merges(:expression_merge_00001).id, :expression_merge => {:expression_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_expression_merge_without_expression_merge_list_id
    UserSession.create users(:librarian1)
    put :update, :id => expression_merges(:expression_merge_00001).id, :expression_merge => {:expression_merge_list_id => nil}
    assert_response :success
  end

  def test_librarian_should_update_expression_merge
    UserSession.create users(:librarian1)
    put :update, :id => expression_merges(:expression_merge_00001).id, :expression_merge => { }
    assert_redirected_to expression_merge_url(assigns(:expression_merge))
  end

  def test_guest_should_not_destroy_expression_merge
    assert_no_difference('ExpressionMerge.count') do
      delete :destroy, :id => expression_merges(:expression_merge_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_expression_merge
    UserSession.create users(:user1)
    assert_no_difference('ExpressionMerge.count') do
      delete :destroy, :id => expression_merges(:expression_merge_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_expression_merge
    UserSession.create users(:librarian1)
    assert_difference('ExpressionMerge.count', -1) do
      delete :destroy, :id => expression_merges(:expression_merge_00001).id
    end

    assert_redirected_to expression_merges_url
  end
end
