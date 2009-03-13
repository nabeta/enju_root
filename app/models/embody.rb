class Embody < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :expression, :counter_cache => true #, :validate => true
  belongs_to :manifestation, :counter_cache => true #, :validate => true

  validates_associated :expression, :manifestation
  validates_presence_of :expression, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :expression_id
  
  @@per_page = 10
  cattr_accessor :per_page

  acts_as_list :scope => :manifestation

end
