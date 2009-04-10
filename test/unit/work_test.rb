require File.dirname(__FILE__) + '/../test_helper'

class WorkTest < ActiveSupport::TestCase
  fixtures :works

  def test_title
    assert works(:work_00001).title
  end

  def test_titles
    assert works(:work_00001).titles
  end

end
