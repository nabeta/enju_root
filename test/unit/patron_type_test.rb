require 'test_helper'

class PatronTypeTest < ActiveSupport::TestCase
  fixtures :patron_types

  # Replace this with your real tests.
end
# == Schema Information
#
# Table name: patron_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

