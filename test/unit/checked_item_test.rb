require File.dirname(__FILE__) + '/../test_helper'

class CheckedItemTest < ActiveSupport::TestCase
  fixtures :users, :patrons, :patron_types, :languages, :countries,
    :checked_items, :items, :manifestations, :exemplifies,
    :expressions, :works, :carrier_types, :expression_forms,
    :shelves

  # Replace this with your real tests.
end
