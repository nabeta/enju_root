require 'test_helper'

class PatronImportResultTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: patron_import_results
#
#  id                    :integer         not null, primary key
#  patron_import_file_id :integer
#  patron_id             :integer
#  user_id               :integer
#  body                  :text
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

