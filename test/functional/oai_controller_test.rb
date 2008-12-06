require File.dirname(__FILE__) + '/../test_helper'

class OaiControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fixtures :manifestations, :manifestation_forms, :library_groups

  def test_guest_should_get_verb_identify
    get :provide, :verb => 'Identify'
    assert_response :success
  end

  def test_guest_should_get_verb_get_record
    get :provide, :verb => 'GetRecord', :identifier => "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/1"
    assert_response :success
  end

  def test_guest_should_not_get_verb_get_record_when_record_is_not_found
    get :provide, :verb => 'GetRecord', :identifier => "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/not_found"
    assert_response :missing
  end
end
