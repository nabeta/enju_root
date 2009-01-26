require 'test_helper'

class NewsPostsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:news_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create news_post" do
    assert_difference('NewsPost.count') do
      post :create, :news_post => { }
    end

    assert_redirected_to news_post_path(assigns(:news_post))
  end

  test "should show news_post" do
    get :show, :id => news_posts(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => news_posts(:one).id
    assert_response :success
  end

  test "should update news_post" do
    put :update, :id => news_posts(:one).id, :news_post => { }
    assert_redirected_to news_post_path(assigns(:news_post))
  end

  test "should destroy news_post" do
    assert_difference('NewsPost.count', -1) do
      delete :destroy, :id => news_posts(:one).id
    end

    assert_redirected_to news_posts_path
  end
end
