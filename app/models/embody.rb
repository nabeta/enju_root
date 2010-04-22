class Embody < ActiveRecord::Base
  belongs_to :expression #, :counter_cache => true #, :validate => true
  belongs_to :manifestation #, :counter_cache => true #, :validate => true

  validates_associated :expression, :manifestation
  validates_presence_of :expression_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :expression_id
  
  def self.per_page
    10
  end

  acts_as_list :scope => :manifestation

  def after_save
    reindex
  end

  def after_destroy
    reindex
  end

  def reindex
    expression.index
    manifestation.index
  end
end
