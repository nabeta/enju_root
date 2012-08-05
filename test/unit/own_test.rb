# == Schema Information
#
# Table name: owns
#
#  id         :integer          not null, primary key
#  patron_id  :integer          not null
#  item_id    :integer          not null
#  position   :integer
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class OwnTest < ActiveSupport::TestCase
  fixtures :owns

  # Replace this with your real tests.
end
