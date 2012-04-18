require 'test_helper'

class SubscribeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :subscribes

end
# == Schema Information
#
# Table name: subscribes
#
#  id              :integer         not null, primary key
#  subscription_id :integer         not null
#  work_id         :integer         not null
#  start_at        :datetime        not null
#  end_at          :datetime        not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

