require 'test_helper'

class ImportedObjectsControllerTest < ActionController::TestCase
  fixtures :imported_objects, :users, :patrons, :events,
    :languages, :user_groups, :libraries, :library_groups, :patron_types,
    :imported_event_files, :imported_patron_files, :imported_resource_files

  def test_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:imported_objects)
  end

  def test_should_get_new
    login_as :librarian1
    get :new
    assert_response :success
  end

  def test_should_create_imported_object
    login_as :librarian1
    assert_difference('ImportedObject.count') do
      post :create, :imported_object => {:imported_file_id => 1, :importable_id => 2, :importable_type => 'Patron'}
    end

    assert_redirected_to imported_object_path(assigns(:imported_object))
  end

  def test_should_show_imported_object
    login_as :librarian1
    get :show, :id => imported_objects(:imported_object_00001).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :librarian1
    get :edit, :id => imported_objects(:imported_object_00001).id
    assert_response :success
  end

  def test_should_update_imported_object
    login_as :librarian1
    put :update, :id => imported_objects(:imported_object_00001).id, :imported_object => { }
    assert_redirected_to imported_object_path(assigns(:imported_object))
  end

  def test_should_destroy_imported_object
    login_as :librarian1
    assert_difference('ImportedObject.count', -1) do
      delete :destroy, :id => imported_objects(:imported_object_00001).id
    end

    assert_redirected_to imported_objects_path
  end
end
