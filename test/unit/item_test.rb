# == Schema Information
#
# Table name: items
#
#  id                          :integer          not null, primary key
#  call_number                 :string(255)
#  item_identifier             :string(255)
#  circulation_status_id       :integer          default(5), not null
#  checkout_type_id            :integer          default(1), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  shelf_id                    :integer          default(1), not null
#  basket_id                   :integer
#  include_supplements         :boolean          default(FALSE), not null
#  checkouts_count             :integer          default(0), not null
#  owns_count                  :integer          default(0), not null
#  resource_has_subjects_count :integer          default(0), not null
#  note                        :text
#  url                         :string(255)
#  price                       :integer
#  lock_version                :integer          default(0), not null
#  required_role_id            :integer          default(1), not null
#  state                       :string(255)
#  required_score              :integer          default(0), not null
#

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  fixtures :items, :shelves, :manifestations, :carrier_types, :exemplifies,
    :creates, :realizes, :produces, :owns,
    :languages, :libraries, :users, :patrons, :user_groups,
    :expressions, :content_types, :reifies, :works, :form_of_works, :embodies, :library_groups,
    :patron_types, :message_templates, :message_requests, :request_status_types

  def test_should_have_library_url
    assert_equal "#{LibraryGroup.site_config.url}libraries/web", items(:item_00001).library_url
  end

end
