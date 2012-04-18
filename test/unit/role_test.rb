require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles

  # Replace this with your real tests.
end
# == Schema Information
#
# Table name: roles
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :string(255)
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  score        :integer         default(0), not null
#  position     :integer
#

