class Exemplify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :manifestation #, :counter_cache => true, :validate => true
  belongs_to :item #, :validate => true

  validates_associated :manifestation, :item
  validates_presence_of :manifestation_id, :item_id
  validates_uniqueness_of :item_id

  acts_as_list :scope => :manifestation_id

  @@per_page = 10
  cattr_accessor :per_page

end
