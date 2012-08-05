# == Schema Information
#
# Table name: patron_merges
#
#  id                   :integer          not null, primary key
#  patron_id            :integer          not null
#  patron_merge_list_id :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class PatronMergeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
end
