class Name < ActiveRecord::Base
  attr_accessible :dates_of_usage, :language_id, :name_string, :scope_of_usage, :script, :transliteration_scheme, :type_of_name
  belongs_to :language
end
