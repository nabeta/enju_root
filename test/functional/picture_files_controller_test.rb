require File.dirname(__FILE__) + '/../test_helper'

class PictureFilesControllerTest < ActionController::TestCase
  fixtures :picture_files, :manifestations, :manifestation_forms, :events, :languages, :users, :user_groups, :patrons, :patron_types, :event_categories, :libraries, :reserves, :library_groups, :countries

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:picture_files)
  end

  def test_librarian_should_get_index_with_manifestation_id
    login_as :librarian1
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert_not_nil assigns(:picture_files)
  end

  def test_librarian_should_get_index_with_event_id
    login_as :librarian1
    get :index, :event_id => 1
    assert_response :success
    assert assigns(:event)
    assert_not_nil assigns(:picture_files)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_new
    login_as :user1
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_not_get_new_without_manifestation_id
    login_as :librarian1
    get :new
    assert_response :success
  end

  def test_librarian_should_get_new_upload
    login_as :librarian1
    get :new, :upload => true, :manifestation_id => 1
    assert_response :success
  end

  def test_librarian_should_get_new_with_manifestation_id
    login_as :librarian1
    get :new, :manifestation_id => 1
    assert_response :success
  end

  def test_librarian_should_get_new_with_event_id
    login_as :librarian1
    get :new, :event_id => 1
    assert_response :success
  end

  def test_guest_should_not_create_picture_file
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Manifestation', :picture_attachable_id => 1, :uploaded_data => 'test upload', :title => 'test upload'}
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_create_picture_file
    login_as :user1
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Manifestation', :picture_attachable_id => 1, :title => 'test upload'}
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_picture_file_without_picture_attachable_type
    login_as :librarian1
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_id => 1, :uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/images/spinner.gif", "image/gif"), :title => 'test upload'}
    end

    assert_response :success
    #assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_not_create_picture_file_without_picture_attachable_id
    login_as :librarian1
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Manifestation', :uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/images/spinner.gif", "image/gif"), :title => 'test upload'}
    end

    assert_response :success
    #assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_not_create_picture_file_without_uploaded_data
    login_as :librarian1
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Manifestation', :picture_attachable_id => 1, :title => 'test upload'}
    end

    assert_response :success
  end

  def test_librarian_should_create_picture_file
    login_as :librarian1
    old_count = PictureFile.count
    #assert_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Shelf', :picture_attachable_id => 1, :uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/images/spinner.gif", "image/gif"), :title => 'test upload'}
    #end
    assert_equal old_count + 2, PictureFile.count

    assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_guest_should_not_show_picture_file
    get :show, :id => picture_files(:picture_file_00001)
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_show_picture_file
    login_as :user1
    get :show, :id => picture_files(:picture_file_00001)
    assert_response :forbidden
  end

  def test_librarian_should_show_picture_file
    login_as :librarian1
    get :show, :id => picture_files(:picture_file_00001)
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :success
  end

  def test_guest_should_not_update_picture_file
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_update_picture_file
    login_as :user1
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_picture_file_without_picture_attachable_id
    login_as :librarian1
    put :update, :id => picture_files(:picture_file_00001), :picture_file => {:picture_attachable_id => nil}
    assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_update_picture_file_without_picture_attachable_type
    login_as :librarian1
    put :update, :id => picture_files(:picture_file_00001), :picture_file => {:picture_attachable_type => nil}
    assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_update_picture_file
    login_as :librarian1
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_guest_should_not_destroy_picture_file
    assert_no_difference('PictureFile.count') do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :redirect
    assert_redirected_to new_session_url
  end

  def test_user_should_not_destroy_picture_file
    login_as :user1
    assert_no_difference('PictureFile.count') do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_picture_file
    login_as :librarian1
    assert_difference('PictureFile.count', -2) do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :redirect
    assert_redirected_to picture_files_url
  end
end
