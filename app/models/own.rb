class Own < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :patron #, :counter_cache => true #, :polymorphic => true, :validate => true
  belongs_to :item #, :counter_cache => true #, :validate => true

  validates_associated :patron, :item
  validates_presence_of :patron, :item
  validates_uniqueness_of :item_id, :scope => :patron_id

  acts_as_list :scope => :item

  cattr_accessor :per_page
  @@per_page = 10
  attr_accessor :item_identifier

  def after_save
    patron.index!
    item.index!
  end

  def after_destroy
    after_save
  end

end
