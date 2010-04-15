class Create < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :patron #, :counter_cache => true #, :polymorphic => true #, :validate => true
  belongs_to :work #, :counter_cache => true #, :validate => true

  validates_associated :patron, :work
  validates_presence_of :patron_id, :work_id
  validates_uniqueness_of :work_id, :scope => :patron_id

  acts_as_list :scope => :work

  def self.per_page
    10
  end

  def after_save
    reindex
  end

  def after_destroy
    reindex
  end

  def reindex
    patron.index
    work.index
  end

end
