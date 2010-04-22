class Produce < ActiveRecord::Base
  belongs_to :patron #, :counter_cache => true #,:polymorphic => true, :validate => true
  belongs_to :manifestation #, :counter_cache => true #, :validate => true

  validates_associated :patron, :manifestation
  validates_presence_of :patron_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :patron_id

  acts_as_list :scope => :manifestation

  def self.per_page
    10
  end

  def after_save
    reindex
  end

  def after_destroy
    reindex
  end

  def reindex
    patron.index
    manifestation.index
  end
end
