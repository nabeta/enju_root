class Reify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :work, :counter_cache => true #, :validate => true
  belongs_to :expression #, :validate => true

  validates_associated :work, :expression
  validates_presence_of :work, :expression
  validates_uniqueness_of :expression_id
  
  cattr_reader :per_page
  @@per_page = 10
  
  acts_as_list :scope => :work

  #def after_save
  #  if self.work
  #    self.work.reload
  #    self.work.save
  #  end
  #  if self.expression
  #    self.expression.reload
  #    self.expression.save
  #  end
  #end

  #def after_destroy
  #  after_save
  #end

end
