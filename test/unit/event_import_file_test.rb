# == Schema Information
#
# Table name: event_import_files
#
#  id                        :integer          not null, primary key
#  parent_id                 :integer
#  filename                  :string(255)
#  content_type              :string(255)
#  size                      :integer
#  file_hash                 :string(255)
#  user_id                   :integer
#  note                      :text
#  executed_at               :datetime
#  state                     :string(255)
#  event_import_file_name    :string(255)
#  event_import_content_type :string(255)
#  event_import_file_size    :integer
#  event_import_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_import_fingerprint  :string(255)
#

require 'test_helper'

class ImportedEventFileTest < ActiveSupport::TestCase
  # Replace this with your real tests.
end
