require File.dirname(__FILE__) + '/../test_helper'

class CheckoutTest < ActiveSupport::TestCase
  fixtures :checkouts, :items, :users

  # Replace this with your real tests.
  def test_checkout_not_returned
    assert Checkout.not_returned.size
  end

  def test_checkout_overdue
    assert Checkout.overdue(Time.zone.now).size > 0
    assert Checkout.not_returned.size > Checkout.overdue(Time.zone.now).size
  end

  def test_send_overdue_notification
    assert_equal Checkout.send_overdue_notification, 0
  end
end
