require 'test_helper'

class PatronRelationshipTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: patron_relationship_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

