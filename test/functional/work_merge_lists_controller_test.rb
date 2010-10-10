require 'test_helper'

class WorkMergeListsControllerTest < ActionController::TestCase
  fixtures :work_merge_lists, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:work_merge_lists), []
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:work_merge_lists), []
  end

  def test_librarian_should_not_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:work_merge_lists)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_work_merge_list
    assert_no_difference('WorkMergeList.count') do
      post :create, :work_merge_list => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work_merge_list
    sign_in users(:user1)
    assert_no_difference('WorkMergeList.count') do
      post :create, :work_merge_list => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_work_merge_list_without_title
    sign_in users(:librarian1)
    assert_no_difference('WorkMergeList.count') do
      post :create, :work_merge_list => { }
    end

    assert_response :success
  end

  def test_librarian_should_create_work_merge_list
    sign_in users(:librarian1)
    assert_difference('WorkMergeList.count') do
      post :create, :work_merge_list => {:title => 'test'}
    end

    assert_redirected_to work_merge_list_url(assigns(:work_merge_list))
  end

  def test_guest_should_not_show_work_merge_list
    get :show, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_work_merge_list
    sign_in users(:user1)
    get :show, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_work_merge_list
    sign_in users(:librarian1)
    get :show, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => work_merge_lists(:work_merge_list_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_work_merge_list
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :work_merge_list => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_work_merge_list
    sign_in users(:user1)
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :work_merge_list => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_work_merge_list_without_title
    sign_in users(:librarian1)
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :work_merge_list => {:title => ""}
    assert_response :success
  end

  def test_librarian_should_update_work_merge_list
    sign_in users(:librarian1)
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :work_merge_list => { }
    assert_redirected_to work_merge_list_url(assigns(:work_merge_list))
  end

  def test_librarian_should_not_merge_works_without_selected_work_id
    sign_in users(:librarian1)
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :mode => 'merge'

    assert_equal 'Specify work id.', flash[:notice]
    assert_redirected_to work_merge_list_url(assigns(:work_merge_list))
  end

  def test_librarian_should_merge_patrons_with_selected_work_id_and_merge_mode
    sign_in users(:librarian1)
    put :update, :id => work_merge_lists(:work_merge_list_00001).id, :selected_work_id => 3, :mode => 'merge'

    assert_equal 'Works are merged successfully.', flash[:notice]
    assert_redirected_to work_merge_list_url(assigns(:work_merge_list))
  end

  def test_guest_should_not_destroy_work_merge_list
    assert_no_difference('WorkMergeList.count') do
      delete :destroy, :id => work_merge_lists(:work_merge_list_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_work_merge_list
    sign_in users(:user1)
    assert_no_difference('WorkMergeList.count') do
      delete :destroy, :id => work_merge_lists(:work_merge_list_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_work_merge_list
    sign_in users(:librarian1)
    assert_difference('WorkMergeList.count', -1) do
      delete :destroy, :id => work_merge_lists(:work_merge_list_00001).id
    end

    assert_redirected_to work_merge_lists_url
  end

end
