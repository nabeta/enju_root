class Produce < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :patron #, :counter_cache => true #,:polymorphic => true, :validate => true
  belongs_to :manifestation #, :counter_cache => true #, :validate => true

  validates_associated :patron, :manifestation
  validates_presence_of :patron, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :patron_id

  acts_as_list :scope => :manifestation

  cattr_accessor :per_page
  @@per_page = 10

  def after_save
    patron.index!
    manifestation.index!
  end

  def after_destroy
    after_save
  end

end
