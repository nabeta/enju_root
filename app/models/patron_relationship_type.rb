class PatronRelationshipType < ActiveRecord::Base
  include OnlyAdministratorCanModify
  has_many :patron_has_patrons
  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  acts_as_list
end
