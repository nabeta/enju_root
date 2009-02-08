require 'test_helper'

class SubjectHeadingTypeHasSubjectsControllerTest < ActionController::TestCase
  fixtures :subject_heading_type_has_subjects

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subject_heading_type_has_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subject_heading_type_has_subject" do
    assert_difference('SubjectHeadingTypeHasSubject.count') do
      post :create, :subject_heading_type_has_subject => { }
    end

    assert_redirected_to subject_heading_type_has_subject_path(assigns(:subject_heading_type_has_subject))
  end

  test "should show subject_heading_type_has_subject" do
    get :show, :id => subject_heading_type_has_subjects(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => subject_heading_type_has_subjects(:one).id
    assert_response :success
  end

  test "should update subject_heading_type_has_subject" do
    put :update, :id => subject_heading_type_has_subjects(:one).id, :subject_heading_type_has_subject => { }
    assert_redirected_to subject_heading_type_has_subject_path(assigns(:subject_heading_type_has_subject))
  end

  test "should destroy subject_heading_type_has_subject" do
    assert_difference('SubjectHeadingTypeHasSubject.count', -1) do
      delete :destroy, :id => subject_heading_type_has_subjects(:one).id
    end

    assert_redirected_to subject_heading_type_has_subjects_path
  end
end
