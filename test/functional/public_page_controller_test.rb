require 'test_helper'

class PublicPageControllerTest < ActionController::TestCase
  test "should_get_screen_shot" do
    get :screen_shot, :url => 'http://next-l.slis.keio.ac.jp/'
    assert_response :success
  end

  test "guest_should_get_opensearch" do
    get :opensearch
    assert_response :success
  end

  test "guest_should_get_msie_acceralator" do
    get :msie_acceralator
    assert_response :success
  end

end
