# == Schema Information
#
# Table name: resource_import_results
#
#  id                      :integer          not null, primary key
#  resource_import_file_id :integer
#  manifestation_id        :integer
#  item_id                 :integer
#  body                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class ResourceImportResultTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
