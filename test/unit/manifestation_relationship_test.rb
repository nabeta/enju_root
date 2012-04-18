require 'test_helper'

class ManifestationRelationshipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: manifestation_relationships
#
#  id                                 :integer         not null, primary key
#  parent_id                          :integer
#  child_id                           :integer
#  manifestation_relationship_type_id :integer
#  position                           :integer
#  created_at                         :datetime        not null
#  updated_at                         :datetime        not null
#

