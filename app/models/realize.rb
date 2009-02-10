class Realize < ActiveRecord::Base
  belongs_to :expression, :counter_cache => true #, :validate => true
  belongs_to :patron, :polymorphic => true, :counter_cache => true #, :validate => true

  validates_associated :expression, :patron
  validates_presence_of :expression, :patron
  validates_uniqueness_of :expression_id, :scope => :patron_id
  
  cattr_reader :per_page
  @@per_page = 10
  
  acts_as_list :scope => :expression

  #def after_save
  #  if self.expression
  #    self.expression.reload
  #    self.expression.save
  #  end
  #  if self.patron
  #    self.patron.reload
  #    self.patron.save
  #  end
  #end

  #def after_destroy
  #  after_save
  #end
end
