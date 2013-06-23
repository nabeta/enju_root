class ControlledAccessPoint < ActiveRecord::Base
  attr_accessible :addition, :base_access_point_id, :base_access_point_language_id, :cataloging_language_id, :designated_usage, :script_of_base_access_point, :script_of_cataloging, :source, :status, :transliteration_scheme_of_cataloging, :transliteratrion_scheme_of_base_access_point, :type_of_controlled_access_point, :undifferentiated_access_point
end
