class Language < ActiveRecord::Base
  attr_accessible :display_name, :iso_639_1, :iso_639_2, :iso_639_3, :name, :native_name, :note, :position
end
