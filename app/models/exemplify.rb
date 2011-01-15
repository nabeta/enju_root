class Exemplify < ActiveRecord::Base
  belongs_to :manifestation #, :counter_cache => true, :validate => true
  belongs_to :item #, :validate => true

  validates_associated :manifestation, :item
  validates_presence_of :manifestation_id, :item_id
  validates_uniqueness_of :item_id

  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :manifestation_id

  def self.per_page
    10
  end

  def reindex
    manifestation.index
    item.index
  end
end
