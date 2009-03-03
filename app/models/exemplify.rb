class Exemplify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :manifestation #, :counter_cache => true, :validate => true
  belongs_to :item #, :validate => true

  validates_associated :manifestation, :item
  validates_presence_of :manifestation, :item
  validates_uniqueness_of :item_id

  acts_as_list :scope => :manifestation_id

  @@per_page = 10
  cattr_reader :per_page

  #def after_save
  #  if self.manifestation
  #    self.manifestation.reload
  #    self.manifestation.save
  #  end
  #  if self.item
  #    self.item.reload
  #    if self.item.manifestation.blank?
  #      self.item.destroy
  #    else
  #      self.item.save
  #    end
  #  end
  #end

  #def after_destroy
  #  after_save
  #end
end
