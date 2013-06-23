class Create < ActiveRecord::Base
  attr_accessible :work_id, :person_id
  belongs_to :work
  belongs_to :person
end
