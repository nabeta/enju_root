require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  fixtures :subscriptions, :works, :subscribes

  def test_subscription_should_respond_to_subscribed
    assert subscriptions(:subscription_00001).subscribed(works(:work_00001))
  end
end
# == Schema Information
#
# Table name: subscriptions
#
#  id               :integer         not null, primary key
#  title            :text            not null
#  note             :text
#  user_id          :integer
#  order_list_id    :integer
#  deleted_at       :datetime
#  subscribes_count :integer         default(0), not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

