# == Schema Information
#
# Table name: realizes
#
#  id              :integer          not null, primary key
#  patron_id       :integer
#  patron_type     :string(255)
#  expression_id   :integer          not null
#  position        :integer
#  type            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  realize_type_id :integer
#

require 'test_helper'

class RealizeTest < ActiveSupport::TestCase
  fixtures :realizes

  # Replace this with your real tests.
end
