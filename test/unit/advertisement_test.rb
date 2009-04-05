require 'test_helper'

class AdvertisementTest < ActiveSupport::TestCase
  fixtures :advertisements

  def test_advertisment_pickup
    assert Advertisement.pickup
  end

end
