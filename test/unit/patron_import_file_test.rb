# == Schema Information
#
# Table name: patron_import_files
#
#  id                         :integer          not null, primary key
#  parent_id                  :integer
#  filename                   :string(255)
#  content_type               :string(255)
#  size                       :integer
#  file_hash                  :string(255)
#  user_id                    :integer
#  note                       :text
#  executed_at                :datetime
#  state                      :string(255)
#  patron_import_file_name    :string(255)
#  patron_import_content_type :string(255)
#  patron_import_file_size    :integer
#  patron_import_updated_at   :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  patron_import_fingerprint  :string(255)
#

require 'test_helper'

class PatronImportFileTest < ActiveSupport::TestCase
  fixtures :patron_import_files, :patrons, :users

  #def test_should_import_patron
  #  assert_difference('Patron.count', 2) do
  #    imported_patron_files(:imported_patron_file_00001).import
  #  end
  #end
end
