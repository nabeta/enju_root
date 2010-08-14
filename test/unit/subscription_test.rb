require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  fixtures :subscriptions, :works, :subscribes

  def test_subscription_should_respond_to_subscribed
    assert_nil subscriptions(:subscription_00001).subscribed(Work.first)
  end
end
