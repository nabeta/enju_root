require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :events

  def test_set_all_day
    events(:event_00001).all_day = true
    assert_equal events(:event_00001).set_all_day, events(:event_00001).end_at.end_of_day
  end

  def test_set_all_day_beginning_of_day
    events(:event_00008).all_day = true
    end_at = events(:event_00008).end_at
    assert_equal events(:event_00008).set_all_day, (end_at - 1.day).end_of_day
  end
end
