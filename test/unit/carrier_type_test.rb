# == Schema Information
#
# Table name: carrier_types
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class CarrierTypeTest < ActiveSupport::TestCase
  fixtures :carrier_types

  # Replace this with your real tests.
end
