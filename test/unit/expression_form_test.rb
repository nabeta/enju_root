require File.dirname(__FILE__) + '/../test_helper'

class ExpressionFormTest < ActiveSupport::TestCase
  fixtures :expression_forms

  # Replace this with your real tests.
  def test_should_have_display_name
    assert_not_nil expression_forms(:expression_form_00001).display_name
  end
end
