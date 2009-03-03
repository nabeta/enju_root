require File.dirname(__FILE__) + '/test_helper'

GOOGLE_APPLICATION_ID = "ABQIAAAA3HdfrnxFAPWyY-aiJUxmqRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQ0KYLwBEKSM7F9gCevcsIf6WPuIQ"

class GoogleMapTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    @map = GoogleMap.new
  end

  def test_new_map_has_empty_markers
    assert @map.markers.empty?
  end

  def test_add_markers
    (1..5).each do |i|
      @map.markers << marker_factory
      assert_equal @map.markers.length, i
      assert @map.to_html.include? "google_map_marker_#{i} = new GMarker(new GLatLng(40, -100));"
    end
  end
  
  def test_center_on_markers_function_for_empty_map
    assert @map.center_on_markers_function_js.include? "google_map.setCenter(new GLatLng(0, 0), 0);"
  end

  def test_center_on_markers_function_for_one_marker
    @map.markers << marker_factory
    assert @map.center_on_markers_function_js.include? "new GLatLngBounds(new GLatLng(40, -100), new GLatLng(40, -100))"
  end

  def test_center_on_markers_function_for_two_markers
    @map.markers << marker_factory
    @map.markers << marker_factory({:lng => 100})
    assert @map.center_on_markers_function_js.include? "new GLatLngBounds(new GLatLng(40, -100), new GLatLng(40, 100))"
  end
  
  def marker_factory(options = {})
    params = {:map => @map, :lat => 40, :lng => -100, :html => 'Test Marker'}.merge(options)
    GoogleMapMarker.new(params)
  end

end
