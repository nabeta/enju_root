# == Schema Information
#
# Table name: user_groups
#
#  id                        :integer          not null, primary key
#  name                      :string(255)      not null
#  string                    :string(255)
#  display_name              :text
#  note                      :text
#  position                  :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#  valid_period_for_new_user :integer          default(0), not null
#  expired_at                :datetime
#

require 'test_helper'

class UserGroupTest < ActiveSupport::TestCase
  fixtures :user_groups

  # Replace this with your real tests.
end
