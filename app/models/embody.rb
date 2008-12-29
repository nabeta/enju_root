class Embody < ActiveRecord::Base
  belongs_to :expression, :counter_cache => true #, :validate => true
  belongs_to :manifestation, :counter_cache => true #, :validate => true

  validates_associated :expression, :manifestation
  validates_presence_of :expression, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :expression_id
  
  @@per_page = 10
  cattr_reader :per_page

  acts_as_list :scope => :manifestation

  #def after_save
  #  if self.expression
  #    self.expression.reload
  #    self.manifestation.save
  #  end
  #  if self.manifestation
  #    self.manifestation.reload
  #    self.manifestation.save
  #  end
  #end

  #def after_destroy
  #  after_save
  #end
end
