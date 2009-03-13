require 'test_helper'

class UserReserveStatTest < ActiveSupport::TestCase
  fixtures :user_reserve_stats

  test "calculate user count" do
    assert user_reserve_stats(:one).calculate_user_count
  end
end
