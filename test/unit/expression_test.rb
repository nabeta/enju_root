require File.dirname(__FILE__) + '/../test_helper'

class ExpressionTest < ActiveSupport::TestCase
  fixtures :expressions, :manifestations, :embodies

  def test_title
    assert expressions(:expression_00001).title
  end
  
  def test_titles
    assert expressions(:expression_00001).titles
  end
end
