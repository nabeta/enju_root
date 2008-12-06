class Produce < ActiveRecord::Base
  belongs_to :patron, :counter_cache => true #, :validate => true
  belongs_to :manifestation, :counter_cache => true #, :validate => true

  validates_associated :patron, :manifestation
  validates_presence_of :patron, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :patron_id

  acts_as_list :scope => :manifestation

  cattr_reader :per_page
  @@per_page = 10

  def after_save
    if self.patron
      self.patron.reload
      self.patron.save
    end
    if self.manifestation
      self.manifestation.reload
      self.manifestation.save
    end
  end

  def after_destroy
    after_save
  end

end
