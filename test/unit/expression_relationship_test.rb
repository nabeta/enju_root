# == Schema Information
#
# Table name: expression_relationships
#
#  id                              :integer          not null, primary key
#  parent_id                       :integer
#  child_id                        :integer
#  expression_relationship_type_id :integer
#  position                        :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'test_helper'

class ExpressionRelationshipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
