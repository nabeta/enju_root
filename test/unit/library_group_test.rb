# == Schema Information
#
# Table name: library_groups
#
#  id                    :integer          not null, primary key
#  name                  :string(255)      not null
#  display_name          :text
#  short_name            :string(255)      not null
#  email                 :string(255)
#  my_networks           :text
#  login_banner          :text
#  note                  :text
#  post_to_union_catalog :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_networks        :text
#  country_id            :integer
#  position              :integer
#  url                   :string(255)      default("http://localhost:3000/")
#

require 'test_helper'

class LibraryGroupTest < ActiveSupport::TestCase
  fixtures :library_groups

  def test_library_group_config
    assert LibraryGroup.site_config
  end

end
