class ResourceHasSubject < ActiveRecord::Base
  belongs_to :subject, :counter_cache => true, :validate => true
  belongs_to :subjectable, :polymorphic => true, :counter_cache => true, :validate => true

  validates_presence_of :subject_id, :subjectable_id, :subjectable_type
  validates_associated :subject, :subjectable
  validates_uniqueness_of :subject_id, :scope => [:subjectable_id, :subjectable_type]

  cattr_reader :per_page
  @@per_page = 10

  def after_save
    self.subject.save
    self.subjectable.save
  end
end
