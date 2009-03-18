require 'test_helper'

class BarcodesControllerTest < ActionController::TestCase
  fixtures :barcodes, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:barcodes)
  end

  def test_user_should_not_get_index
    login_as :user1
    get :index
    assert_response :forbidden
    assert_nil assigns(:barcodes)
  end

  def test_librarian_should_get_index
    login_as :librarian1
    get :index
    assert_response :success
    assert_not_nil assigns(:barcodes)
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

  def test_guest_should_not_create_barcode
    assert_no_difference('Barcode.count') do
      post :create, :barcode => {:code_word => 'test'}
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_barcode
    login_as :user1
    assert_no_difference('Barcode.count') do
      post :create, :barcode => {:code_word => 'test'}
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_barcode
    login_as :librarian1
    assert_difference('Barcode.count') do
      post :create, :barcode => {:code_word => 'test'}
    end

    assert_redirected_to barcode_path(assigns(:barcode))
  end

  def test_guest_should_show_barcode
    get :show, :id => barcodes(:barcode_00001).id
    assert_response :success
  end

  def test_user_should_show_barcode
    login_as :user1
    get :show, :id => barcodes(:barcode_00001).id
    assert_response :success
  end

  def test_librarian_should_show_barcode
    login_as :librarian1
    get :show, :id => barcodes(:barcode_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => barcodes(:barcode_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    login_as :user1
    get :edit, :id => barcodes(:barcode_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    login_as :librarian1
    get :edit, :id => barcodes(:barcode_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_barcode
    put :update, :id => barcodes(:barcode_00001).id, :barcode => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_barcode
    login_as :user1
    put :update, :id => barcodes(:barcode_00001).id, :barcode => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_barcode
    login_as :librarian1
    put :update, :id => barcodes(:barcode_00001).id, :barcode => {:code_word => 'test'}
    assert_redirected_to barcode_path(assigns(:barcode))
  end

  def test_guest_should_not_destroy_barcode
    assert_no_difference('Barcode.count') do
      delete :destroy, :id => barcodes(:barcode_00001).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_barcode
    login_as :user1
    assert_no_difference('Barcode.count') do
      delete :destroy, :id => barcodes(:barcode_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_barcode
    login_as :librarian1
    assert_difference('Barcode.count', -1) do
      delete :destroy, :id => barcodes(:barcode_00001).id
    end

    assert_redirected_to barcodes_path
  end
end
