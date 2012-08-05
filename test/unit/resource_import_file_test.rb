# == Schema Information
#
# Table name: resource_import_files
#
#  id                           :integer          not null, primary key
#  parent_id                    :integer
#  filename                     :string(255)
#  content_type                 :string(255)
#  size                         :integer
#  file_hash                    :string(255)
#  user_id                      :integer
#  note                         :text
#  executed_at                  :datetime
#  state                        :string(255)
#  resource_import_file_name    :string(255)
#  resource_import_content_type :string(255)
#  resource_import_file_size    :integer
#  resource_import_updated_at   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  resource_import_fingerprint  :string(255)
#  edit_mode                    :string(255)
#  error_message                :text
#

require 'test_helper'

class ResourceImportFileTest < ActiveSupport::TestCase
  # Replace this with your real tests.
end
