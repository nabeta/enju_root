require 'test_helper'

class WorkMergesControllerTest < ActionController::TestCase
  fixtures :work_merges, :works, :work_merge_lists, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:work_merges)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:work_merges)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:work_merges)
  end

  def test_librarian_should_get_index_with_work_id
    login_as :librarian1
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:work)
    assert_not_nil assigns(:work_merges)
  end

  def test_librarian_should_get_index_with_work_merge_list_id
    login_as :librarian1
    get :index, :work_merge_list_id => 1
    assert_response :success
    assert assigns(:work_merge_list)
    assert_not_nil assigns(:work_merges)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_get_new
    login_as :librarian1
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_work_merge
    assert_no_difference('WorkMerge.count') do
      post :create, :work_merge => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work_merge
    login_as :user1
    assert_no_difference('WorkMerge.count') do
      post :create, :work_merge => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_work_merge_without_work_id
    login_as :librarian1
    assert_no_difference('WorkMerge.count') do
      post :create, :work_merge => {:work_merge_list_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_work_merge_without_work_merge_list_id
    login_as :librarian1
    assert_no_difference('WorkMerge.count') do
      post :create, :work_merge => {:work_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_work_merge
    login_as :librarian1
    assert_difference('WorkMerge.count') do
      post :create, :work_merge => {:work_id => 1, :work_merge_list_id => 1}
    end

    assert_redirected_to work_merge_url(assigns(:work_merge))
  end

  def test_guest_should_not_show_work_merge
    get :show, :id => work_merges(:work_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_work_merge
    login_as :user1
    get :show, :id => work_merges(:work_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_work_merge
    login_as :librarian1
    get :show, :id => work_merges(:work_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => work_merges(:work_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => work_merges(:work_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => work_merges(:work_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_work_merge
    put :update, :id => work_merges(:work_merge_00001).id, :work_merge => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_work_merge
    login_as :user1
    put :update, :id => work_merges(:work_merge_00001).id, :work_merge => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_work_merge_without_work_id
    login_as :librarian1
    put :update, :id => work_merges(:work_merge_00001).id, :work_merge => {:work_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_work_merge_without_work_merge_list_id
    login_as :librarian1
    put :update, :id => work_merges(:work_merge_00001).id, :work_merge => {:work_merge_list_id => nil}
    assert_response :success
  end

  def test_librarian_should_update_work_merge
    login_as :librarian1
    put :update, :id => work_merges(:work_merge_00001).id, :work_merge => { }
    assert_redirected_to work_merge_url(assigns(:work_merge))
  end

  def test_guest_should_not_destroy_work_merge
    assert_no_difference('WorkMerge.count') do
      delete :destroy, :id => work_merges(:work_merge_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_work_merge
    login_as :user1
    assert_no_difference('WorkMerge.count') do
      delete :destroy, :id => work_merges(:work_merge_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_work_merge
    login_as :librarian1
    assert_difference('WorkMerge.count', -1) do
      delete :destroy, :id => work_merges(:work_merge_00001).id
    end

    assert_redirected_to work_merges_url
  end
end
