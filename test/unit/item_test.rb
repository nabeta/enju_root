require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  fixtures :items, :circulation_statuses, :shelves, :manifestations, :carrier_types, :exemplifies,
    :creates, :realizes, :produces, :owns,
    :languages, :libraries, :users, :patrons, :user_groups,
    :expressions, :content_types, :reifies, :works, :form_of_works, :embodies, :library_groups, :bookstores,
    :patron_types, :message_templates, :message_requests, :barcodes, :request_status_types

  def test_should_have_library_url
    assert_equal "#{LibraryGroup.site_config.url}libraries/web", items(:item_00001).library_url
  end

end
