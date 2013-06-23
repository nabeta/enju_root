class Subject < ActiveRecord::Base
  attr_accessible :subject_heading_id, :subject_type_id, :term
end
