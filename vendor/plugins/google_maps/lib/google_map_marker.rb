class GoogleMapMarker
  #include Reloadable
  
  include ActionView::Helpers::JavaScriptHelper
  
  attr_accessor :dom_id,
                :lat,
                :lng,
                :html,
                :marker_icon_path,
                :marker_hover_text,
                :map,
                :icon
                
  def initialize(options = {})
    options.each_pair { |key, value| send("#{key}=", value) }
    if lat.blank? or lng.blank? or !map or !map.kind_of?(GoogleMap)
      raise "Must set lat, lng, and map for GoogleMapMarker."
    end
    if dom_id.blank?
      # This needs self to set the attr_accessor, why?
      self.dom_id = "#{map.dom_id}_marker_#{map.markers.size + 1}"
    end
  end
  
  def open_info_window_function
    js = []
    
    js << "function #{dom_id}_infowindow_function() {"
    js << "  #{dom_id}.openInfoWindowHtml(\"#{escape_javascript(html)}\")"
    js << "}"
    
    return js.join("\n")
  end
  
  def open_info_window
    "#{dom_id}_infowindow_function();"
  end
  
  def to_js
    js = []
    
    # If a icon is specified, use it in marker creation.
    i = ", #{icon.dom_id}" if icon
    h = ", title: '#{marker_hover_text}'" if marker_hover_text
    
    i = ", { icon: new GIcon( G_DEFAULT_ICON, '#{marker_icon_path}')#{h}}" if marker_icon_path

puts i

    # js << "map.addOverlay( marker = new GMarker( new GLatLng(#{lat}, #{lng})), { "
    # js << "  icon: new GIcon( G_DEFAULT_ICON, '#{marker_icon_path}' ), "
    # js << "  title: '#{marker_hover_text}'"
    # js << "} ) );"			
		
    js << "#{dom_id} = new GMarker(new GLatLng(#{lat}, #{lng})#{i});"
    
    if self.html
      js << "GEvent.addListener(#{dom_id}, 'click', function() {#{dom_id}_infowindow_function()});"
    end
    
    js << "#{map.dom_id}.addOverlay(#{dom_id});"
    
    return js.join("\n")
  end

end