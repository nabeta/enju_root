class WorkRelationshipType < ActiveRecord::Base
  attr_accessible :name, :position, :definition, :url
  acts_as_list
end
