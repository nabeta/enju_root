# == Schema Information
#
# Table name: libraries
#
#  id                    :integer          not null, primary key
#  patron_id             :integer
#  patron_type           :string(255)
#  name                  :string(255)      not null
#  display_name          :text
#  short_display_name    :string(255)      not null
#  zip_code              :string(255)
#  street                :text
#  locality              :text
#  region                :text
#  telephone_number_1    :string(255)
#  telephone_number_2    :string(255)
#  fax_number            :string(255)
#  note                  :text
#  call_number_rows      :integer          default(1), not null
#  call_number_delimiter :string(255)      default("|"), not null
#  library_group_id      :integer          default(1), not null
#  users_count           :integer          default(0), not null
#  position              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deleted_at            :datetime
#  opening_hour          :text
#  latitude              :decimal(, )
#  longitude             :decimal(, )
#  country_id            :integer
#  isil                  :string(255)
#

require 'test_helper'

class LibraryTest < ActiveSupport::TestCase
  fixtures :libraries

  def test_library_should_create_default_shelf
    patron = Patron.create!(:full_name => 'test')
    library = Library.create!(:name => 'test', :short_display_name => 'test')
    assert library.shelves.first
    assert_equal library.shelves.first.name, 'test_default'
  end
end
