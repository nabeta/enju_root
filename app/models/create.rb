class Create < ActiveRecord::Base
  belongs_to :patron, :polymorphic => true, :counter_cache => true #, :validate => true
  belongs_to :work, :counter_cache => true #, :validate => true

  validates_associated :patron, :work
  validates_presence_of :patron, :work
  validates_uniqueness_of :work_id, :scope => :patron_id

  acts_as_list :scope => :work

  cattr_reader :per_page
  @@per_page = 10

  #def after_save
  #  if self.work
  #    self.work.reload
  #    self.work.save
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
