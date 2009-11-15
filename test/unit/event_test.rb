require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :events

  def test_set_all_day
    events(:event_00001).all_day = true
    assert_equal events(:event_00001).set_all_day, events(:event_00001).end_at.end_of_day
  end
end
