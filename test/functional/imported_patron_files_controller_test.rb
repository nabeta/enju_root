require 'test_helper'

class ImportedPatronFilesControllerTest < ActionController::TestCase
  fixtures :imported_patron_files, :users, :roles, :patrons, :db_files,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories,
    :imported_objects

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:imported_patron_files)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:imported_patron_files)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:imported_patron_files)
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

  def test_guest_should_not_create_imported_patron_file
    assert_no_difference('ImportedPatronFile.count') do
      post :create, :imported_patron_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_imported_patron_file
    login_as :user1
    assert_no_difference('ImportedPatronFile.count') do
      post :create, :imported_patron_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_imported_patron_file
    login_as :librarian1
    old_patrons_count = Patron.count
    assert_difference('ImportedPatronFile.count') do
      post :create, :imported_patron_file => {:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/imported_patron_file_sample1.tsv") }
    end
    assert_difference('Patron.count', 2) do
      assigns(:imported_patron_file).import
    end
    assert_equal '田辺浩介', Patron.find(:first, :order => 'id DESC').full_name

    assert_redirected_to imported_patron_file_path(assigns(:imported_patron_file))
  end

  def test_librarian_should_create_imported_patron_file
    login_as :librarian1
    old_patrons_count = Patron.count
    assert_difference('ImportedPatronFile.count') do
      post :create, :imported_patron_file => {:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/imported_patron_file_sample2.tsv") }
    end
    assert_difference('Patron.count', 1) do
      assigns(:imported_patron_file).import
    end
    #assert_equal old_patrons_count + 1, Patron.count
    #assert_equal '日本語の名前', Patron.find(:first, :order => 'id DESC').full_name

    assert_redirected_to imported_patron_file_path(assigns(:imported_patron_file))
  end

  def test_guest_should_not_show_imported_patron_file
    get :show, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_imported_patron_file
    login_as :user1
    get :show, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_imported_patron_file
    login_as :librarian1
    get :show, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => imported_patron_files(:imported_patron_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_imported_patron_file
    put :update, :id => imported_patron_files(:imported_patron_file_00003).id, :imported_patron_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_imported_patron_file
    login_as :user1
    put :update, :id => imported_patron_files(:imported_patron_file_00003).id, :imported_patron_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_imported_patron_file
    login_as :librarian1
    put :update, :id => imported_patron_files(:imported_patron_file_00003).id, :imported_patron_file => { }
    assert_redirected_to imported_patron_file_path(assigns(:imported_patron_file))
  end

  def test_guest_should_not_destroy_imported_patron_file
    assert_no_difference('ImportedPatronFile.count') do
      delete :destroy, :id => imported_patron_files(:imported_patron_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_imported_patron_file
    login_as :user1
    assert_no_difference('ImportedPatronFile.count') do
      delete :destroy, :id => imported_patron_files(:imported_patron_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_imported_patron_file
    login_as :librarian1
    assert_difference('ImportedPatronFile.count', -1) do
      delete :destroy, :id => imported_patron_files(:imported_patron_file_00003).id
    end

    assert_redirected_to imported_patron_files_path
  end
end
