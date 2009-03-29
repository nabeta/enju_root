require 'test_helper'

class ExpressionMergeListsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :expression_merge_lists, :expressions, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:expression_merge_lists)
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:expression_merge_lists)
  end

  def test_librarian_should_not_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_merge_lists)
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

  def test_guest_should_not_create_expression_merge_list
    assert_no_difference('ExpressionMergeList.count') do
      post :create, :expression_merge_list => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_expression_merge_list
    UserSession.create users(:user1)
    assert_no_difference('ExpressionMergeList.count') do
      post :create, :expression_merge_list => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_expression_merge_list_without_title
    UserSession.create users(:librarian1)
    assert_no_difference('ExpressionMergeList.count') do
      post :create, :expression_merge_list => { }
    end

    assert_response :success
  end

  def test_librarian_should_create_expression_merge_list
    UserSession.create users(:librarian1)
    assert_difference('ExpressionMergeList.count') do
      post :create, :expression_merge_list => {:title => 'test'}
    end

    assert_redirected_to expression_merge_list_url(assigns(:expression_merge_list))
  end

  def test_guest_should_not_show_expression_merge_list
    get :show, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_expression_merge_list
    UserSession.create users(:user1)
    get :show, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_expression_merge_list
    UserSession.create users(:librarian1)
    get :show, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => expression_merge_lists(:expression_merge_list_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_expression_merge_list
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :expression_merge_list => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_expression_merge_list
    UserSession.create users(:user1)
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :expression_merge_list => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_expression_merge_list_without_title
    UserSession.create users(:librarian1)
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :expression_merge_list => {:title => ""}
    assert_response :success
  end

  def test_librarian_should_update_expression_merge_list
    UserSession.create users(:librarian1)
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :expression_merge_list => { }
    assert_redirected_to expression_merge_list_url(assigns(:expression_merge_list))
  end

  def test_librarian_should_not_merge_works_without_selected_expression_id
    UserSession.create users(:librarian1)
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :mode => 'merge'

    assert_equal 'Specify expression id.', flash[:notice]
    assert_redirected_to expression_merge_list_url(assigns(:expression_merge_list))
  end

  def test_librarian_should_merge_expressions_with_selected_expression_id_and_merge_mode
    UserSession.create users(:librarian1)
    put :update, :id => expression_merge_lists(:expression_merge_list_00001).id, :selected_expression_id => 3, :mode => 'merge'

    assert_equal 'Expressions are merged successfully.', flash[:notice]
    assert_redirected_to expression_merge_list_url(assigns(:expression_merge_list))
  end

  def test_guest_should_not_destroy_expression_merge_list
    assert_no_difference('ExpressionMergeList.count') do
      delete :destroy, :id => expression_merge_lists(:expression_merge_list_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_expression_merge_list
    UserSession.create users(:user1)
    assert_no_difference('ExpressionMergeList.count') do
      delete :destroy, :id => expression_merge_lists(:expression_merge_list_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_expression_merge_list
    UserSession.create users(:librarian1)
    assert_difference('ExpressionMergeList.count', -1) do
      delete :destroy, :id => expression_merge_lists(:expression_merge_list_00001).id
    end

    assert_redirected_to expression_merge_lists_url
  end

end
