require 'test_helper'

class AttachmentFilesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fixtures :attachment_files, :manifestations, :manifestation_forms,
    :events, :languages, :users, :user_groups, :patrons, :patron_types,
    :event_categories, :libraries, :reserves, :library_groups, :countries,
    :frequency_of_issues, :work_forms, :expression_forms

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    UserSession.create users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    UserSession.create users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:attachment_files)
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

  def test_guest_should_not_create_attachment_file
    assert_no_difference('AttachmentFile.count') do
      post :create, :attachment_file => {:uploaded_data => 'test upload', :title => 'test upload'}
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_attachment_file
    UserSession.create users(:user1)
    assert_no_difference('AttachmentFile.count') do
      post :create, :attachment_file => {:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/images/spinner.gif"), :title => 'test upload'}
    end

    assert_response :forbidden
    #assert_not_nil assigns(:attachment_file).file_hash
    #assert_redirected_to attachment_file_url(assigns(:attachment_file))
  end

  def test_librarian_should_create_attachment_file
    UserSession.create users(:librarian1)
    old_count = Manifestation.count
    #assert_difference('AttachmentFile.count') do
      post :create, :attachment_file => {:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/public/images/spinner.gif"), :title => 'test upload'}
    #end

    assert_equal Manifestation.count, old_count + 1
    assert assigns(:attachment_file).manifestation
    assert_equal assigns(:attachment_file).manifestation.manifestation_form.name, 'file'
    assert_not_nil assigns(:attachment_file).file_hash
    assert_redirected_to attachment_file_url(assigns(:attachment_file))
  end

  def test_librarian_should_not_create_attachment_file_without_uploaded_data
    UserSession.create users(:librarian1)
    assert_no_difference('AttachmentFile.count') do
      post :create, :attachment_file => {:title => 'test upload'}
    end

    assert_response :success
  end

  def test_guest_should_not_show_attachment_file
    get :show, :id => attachment_files(:attachment_file_00001)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_attachment_file
    UserSession.create users(:user1)
    get :show, :id => attachment_files(:attachment_file_00001)
    assert_response :forbidden
  end

  def test_librarian_should_show_attachment_file
    UserSession.create users(:librarian1)
    get :show, :id => attachment_files(:attachment_file_00001)
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => attachment_files(:attachment_file_00001)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    UserSession.create users(:user1)
    get :edit, :id => attachment_files(:attachment_file_00001)
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    UserSession.create users(:librarian1)
    get :edit, :id => attachment_files(:attachment_file_00001)
    assert_response :success
  end

  def test_guest_should_not_update_attachment_file
    put :update, :id => attachment_files(:attachment_file_00001), :attachment_file => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_attachment_file
    UserSession.create users(:user1)
    put :update, :id => attachment_files(:attachment_file_00001), :attachment_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_attachment_file_without_manifestation_id
    UserSession.create users(:librarian1)
    put :update, :id => attachment_files(:attachment_file_00001), :attachment_file => {:manifestation_id => nil}
    #assert_redirected_to attachment_file_url(assigns(:attachment_file))
    assert_response :success
  end

  def test_librarian_should_update_attachment_file
    UserSession.create users(:librarian1)
    put :update, :id => attachment_files(:attachment_file_00001), :attachment_file => {:manifestation_id => 1}
    assert_redirected_to attachment_file_url(assigns(:attachment_file))
  end

  def test_guest_should_not_destroy_attachment_file
    assert_no_difference('AttachmentFile.count') do
      delete :destroy, :id => attachment_files(:attachment_file_00001)
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_attachment_file
    UserSession.create users(:user1)
    assert_no_difference('AttachmentFile.count') do
      delete :destroy, :id => attachment_files(:attachment_file_00001)
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_attachment_file
    UserSession.create users(:librarian1)
    assert_difference('AttachmentFile.count', -1) do
      delete :destroy, :id => attachment_files(:attachment_file_00001)
    end

    assert_response :redirect
    assert_redirected_to attachment_files_url
  end
end
