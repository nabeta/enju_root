class Concept < ActiveRecord::Base
  acts_as_soft_deletable
  acts_as_solr :fields => [:term, :note]

  validates_presence_of :term

  @@per_page = 10
  cattr_reader :per_page
end
