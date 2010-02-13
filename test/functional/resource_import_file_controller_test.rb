require 'test_helper'

class ResourceImportFilesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :resource_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories, :circulation_statuses,
    :imported_objects

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:resource_import_files)
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:resource_import_files)
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_import_files)
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

  def test_guest_should_not_create_resource_import_file
    assert_no_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_resource_import_file
    UserSession.create users(:user1)
    assert_no_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_resource_import_file
    UserSession.create users(:librarian1)
    old_patrons_count = Patron.count
    old_manifestations_count = Manifestation.count
    assert_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => {:resource_import => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/resource_import_file_sample1.tsv") }
    end
    # 後でバッチで処理する
    assigns(:resource_import_file).import
    assert_equal old_manifestations_count + 5, Manifestation.count
    assert_equal old_patrons_count + 4, Patron.count

    assert_equal 'librarian1', assigns(:resource_import_file).user.login
    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
  end

  def test_librarian_should_create_resource_import_file_only_isbn
    UserSession.create users(:librarian1)
    old_patrons_count = Patron.count
    old_manifestations_count = Manifestation.count
    assert_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => {:resource_import => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/isbn_sample.txt") }
    end
    # 後でバッチで処理する
    #assert_equal old_manifestations_count + 1, Manifestation.count
    #assert_equal old_patrons_count + 5, Patron.count

    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
  end

  def test_guest_should_not_show_resource_import_file
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_resource_import_file
    UserSession.create users(:user1)
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_resource_import_file
    UserSession.create users(:librarian1)
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_resource_import_file
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_resource_import_file
    UserSession.create users(:user1)
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_resource_import_file
    UserSession.create users(:librarian1)
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
  end

  def test_guest_should_not_destroy_resource_import_file
    assert_no_difference('ResourceImportFile.count') do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_resource_import_file
    UserSession.create users(:user1)
    assert_no_difference('ResourceImportFile.count') do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_resource_import_file
    UserSession.create users(:librarian1)
    assert_difference('ResourceImportFile.count', -1) do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_redirected_to resource_import_files_path
  end
end