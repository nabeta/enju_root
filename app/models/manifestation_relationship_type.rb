class ManifestationRelationshipType < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :manifestation_has_manifestations
  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  acts_as_list
end
