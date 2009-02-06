class Place < ActiveRecord::Base
  #has_many :work_has_places
  #has_many :works, :through => :work_has_places
  has_many :works, :as => :subjects
  has_many :classifications, :as => :subjects

  acts_as_soft_deletable
  acts_as_solr :fields => [:term, :note]

  validates_presence_of :term

  @@per_page = 10
  cattr_reader :per_page
end
