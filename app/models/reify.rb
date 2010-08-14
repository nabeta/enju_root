class Reify < ActiveRecord::Base
  belongs_to :work
  belongs_to :expression

  validates_associated :work, :expression
  validates_presence_of :work_id, :expression_id
  validates_uniqueness_of :expression_id, :scope => :work_id

  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :work

  def self.per_page
    10
  end

  def reindex
    work.index
    expression.index
  end
end
