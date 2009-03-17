class Reify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :work #, :counter_cache => true #, :validate => true
  belongs_to :expression #, :validate => true

  validates_associated :work, :expression
  validates_presence_of :work, :expression
  validates_uniqueness_of :expression_id, :scope => :work_id
  
  cattr_accessor :per_page
  @@per_page = 10
  
  acts_as_list :scope => :work

end
