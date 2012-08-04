# == Schema Information
#
# Table name: creates
#
#  id             :integer          not null, primary key
#  patron_id      :integer          not null
#  work_id        :integer          not null
#  position       :integer
#  type           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  create_type_id :integer
#

require 'test_helper'

class CreateTest < ActiveSupport::TestCase
  fixtures :creates

  # Replace this with your real tests.
end
