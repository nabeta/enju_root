class Own < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :patron #, :counter_cache => true #, :polymorphic => true, :validate => true
  belongs_to :item #, :counter_cache => true #, :validate => true

  validates_associated :patron, :item
  validates_presence_of :patron_id, :item_id
  validates_uniqueness_of :item_id, :scope => :patron_id

  acts_as_list :scope => :item

  def self.per_page
    10
  end
  attr_accessor :item_identifier

  def after_save
    reindex
  end

  def after_destroy
    reindex
  end

  def reindex
    patron.index
    item.index
  end

end
