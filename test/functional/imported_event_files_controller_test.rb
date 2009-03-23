require 'test_helper'

class ImportedEventFilesControllerTest < ActionController::TestCase
  fixtures :imported_event_files, :users, :roles, :patrons, :db_files,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories,
    :imported_objects

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:imported_event_files)
  end

  def test_user_should_not_get_index
    set_session_for users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:imported_event_files)
  end

  def test_librarian_should_get_index
    set_session_for users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:imported_event_files)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
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
    assert_response :success
  end

  def test_guest_should_not_create_imported_event_file
    assert_no_difference('ImportedEventFile.count') do
      post :create, :imported_event_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_imported_event_file
    set_session_for users(:user1)
    assert_no_difference('ImportedEventFile.count') do
      post :create, :imported_event_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_imported_event_file
    set_session_for users(:librarian1)
    assert_difference('ImportedEventFile.count') do
      post :create, :imported_event_file => {:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/imported_event_file_sample1.tsv") }
    end

    assert_redirected_to imported_event_file_url(assigns(:imported_event_file))
  end

  def test_guest_should_not_show_imported_event_file
    get :show, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_imported_event_file
    set_session_for users(:user1)
    get :show, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_imported_event_file
    set_session_for users(:librarian1)
    get :show, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    set_session_for users(:user1)
    get :edit, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    set_session_for users(:librarian1)
    get :edit, :id => imported_event_files(:imported_event_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_imported_event_file
    put :update, :id => imported_event_files(:imported_event_file_00003).id, :imported_event_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_imported_event_file
    set_session_for users(:user1)
    put :update, :id => imported_event_files(:imported_event_file_00003).id, :imported_event_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_imported_event_file
    set_session_for users(:librarian1)
    put :update, :id => imported_event_files(:imported_event_file_00003).id, :imported_event_file => { }
    assert_redirected_to imported_event_file_url(assigns(:imported_event_file))
  end

  def test_guest_should_not_destroy_imported_event_file
    assert_no_difference('ImportedEventFile.count') do
      delete :destroy, :id => imported_event_files(:imported_event_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_imported_event_file
    set_session_for users(:user1)
    assert_no_difference('ImportedEventFile.count') do
      delete :destroy, :id => imported_event_files(:imported_event_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_imported_event_file
    set_session_for users(:librarian1)
    assert_difference('ImportedEventFile.count', -1) do
      delete :destroy, :id => imported_event_files(:imported_event_file_00003).id
    end

    assert_redirected_to imported_event_files_path
  end
end
