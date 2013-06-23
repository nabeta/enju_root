class Produce < ActiveRecord::Base
  attr_accessible :manifestation_id, :person_id
  belongs_to :manifestation
  belongs_to :person
end
