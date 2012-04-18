require 'test_helper'

class EmbodyTest < ActiveSupport::TestCase
  fixtures :embodies

  # Replace this with your real tests.
end
# == Schema Information
#
# Table name: embodies
#
#  id               :integer         not null, primary key
#  expression_id    :integer         not null
#  manifestation_id :integer         not null
#  type             :string(255)
#  position         :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

