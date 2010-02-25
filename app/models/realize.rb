class Realize < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :expression #, :counter_cache => true #, :validate => true
  belongs_to :patron #, :counter_cache => true #, :polymorphic => true, :validate => true

  validates_associated :expression, :patron
  validates_presence_of :expression_id, :patron_id
  validates_uniqueness_of :expression_id, :scope => :patron_id
  
  def self.per_page
    10
  end
  
  acts_as_list :scope => :expression

  def after_save
    patron.index!
    expression.index!
  end

  def after_destroy
    after_save
  end

end
