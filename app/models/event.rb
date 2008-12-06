class Event < ActiveRecord::Base
  named_scope :closing_days, :include => :event_category, :conditions => ['event_categories.name = ?', 'closed']

  belongs_to :event_category, :validate => true
  belongs_to :library, :validate => true
  has_many :attachment_files, :as => :attachable
  has_many :picture_files, :as => :picture_attachable

  acts_as_taggable
  acts_as_paranoid
  acts_as_solr :fields => [:title, :note, {:created_at => :date}, {:updated_at => :date}, {:started_at => :date}, {:ended_at => :date}], :auto_commit => false
  validates_presence_of :title, :library, :event_category
  validates_associated :library, :event_category

  cattr_reader :per_page
  @@per_page = 10

  def before_save
    if self.started_at.blank?
      self.started_at = Time.today
    end
    if self.ended_at.blank?
      self.ended_at = Time.today.end_of_day
    end
  end

  def validate
    if self.started_at and self.ended_at
      if self.started_at > self.ended_at
        errors.add(:started_at)
        errors.add(:ended_at)
      end
    end
  end
end
