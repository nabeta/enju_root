require 'test_helper'

class FrequencyTest < ActiveSupport::TestCase
  fixtures :frequencies

  # Replace this with your real tests.
  def test_should_have_display_name
    assert_not_nil frequencies(:frequency_00001).display_name
  end
end
# == Schema Information
#
# Table name: frequencies
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

