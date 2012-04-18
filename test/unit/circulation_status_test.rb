require 'test_helper'

class CirculationStatusTest < ActiveSupport::TestCase
  fixtures :circulation_statuses

  # Replace this with your real tests.
end
# == Schema Information
#
# Table name: circulation_statuses
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

