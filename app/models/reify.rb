class Reify < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :work #, :counter_cache => true #, :validate => true
  belongs_to :expression #, :validate => true
  belongs_to :relationship_type, :class_name => 'WorkToExpressionRelType'

  validates_associated :work, :expression
  validates_presence_of :work_id, :expression_id
  validates_uniqueness_of :expression_id, :scope => :work_id
  
  def self.per_page
    10
  end
  
  acts_as_list :scope => :work

  def after_save
    work.index!
    expression.index!
  end

  def after_destroy
    after_save
  end

end
