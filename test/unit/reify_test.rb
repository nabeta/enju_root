# == Schema Information
#
# Table name: reifies
#
#  id                   :integer          not null, primary key
#  work_id              :integer          not null
#  expression_id        :integer          not null
#  position             :integer
#  type                 :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  relationship_type_id :integer
#

require 'test_helper'

class ReifyTest < ActiveSupport::TestCase
  fixtures :reifies

  # Replace this with your real tests.
end
