# == Schema Information
#
# Table name: produces
#
#  id               :integer          not null, primary key
#  patron_id        :integer          not null
#  manifestation_id :integer          not null
#  position         :integer
#  type             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  produce_type_id  :integer
#

require 'test_helper'

class ProduceTest < ActiveSupport::TestCase
  fixtures :produces

  # Replace this with your real tests.
end
