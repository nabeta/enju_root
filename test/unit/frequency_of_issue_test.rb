require File.dirname(__FILE__) + '/../test_helper'

class FrequencyOfIssueTest < ActiveSupport::TestCase
  fixtures :frequency_of_issues

  # Replace this with your real tests.
  def test_should_have_display_name
    assert_not_nil frequency_of_issues(:frequency_of_issue_00001).display_name
  end
end
