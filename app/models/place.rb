class Place < ActiveRecord::Base
  has_many :works, :as => :subjects
  has_many :classifications, :as => :subjects

  #acts_as_soft_deletable
  acts_as_solr :fields => [:term, :note]

  validates_presence_of :term

  @@per_page = 10
  cattr_accessor :per_page
end
