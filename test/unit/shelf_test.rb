# == Schema Information
#
# Table name: shelves
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  library_id   :integer          default(1), not null
#  items_count  :integer          default(0), not null
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#

require 'test_helper'

class ShelfTest < ActiveSupport::TestCase
  fixtures :shelves

  # Replace this with your real tests.
end
