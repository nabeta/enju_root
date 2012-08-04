# == Schema Information
#
# Table name: languages
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  native_name  :string(255)
#  display_name :text
#  iso_639_1    :string(255)
#  iso_639_2    :string(255)
#  iso_639_3    :string(255)
#  note         :text
#  position     :integer
#

require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  fixtures :languages

  # Replace this with your real tests.
end
