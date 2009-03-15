require 'test_helper'

class UserCheckoutStatTest < ActiveSupport::TestCase
  fixtures :user_checkout_stats

  test "calculate user count" do
    assert user_checkout_stats(:one).calculate_user_count
  end
end
