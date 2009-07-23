class Event < ActiveRecord::Base
  include OnlyLibrarianCanModify

  named_scope :closing_days, :include => :event_category, :conditions => ['event_categories.name = ?', 'closed']
  named_scope :on, lambda {|datetime| {:conditions => ['started_at >= ? AND ended_at < ?', Time.zone.parse(datetime).beginning_of_day, Time.zone.parse(datetime).tomorrow.beginning_of_day + 1]}}
  named_scope :past, lambda {|datetime| {:conditions => ['ended_at <= ?', Time.zone.parse(datetime).beginning_of_day]}}
  named_scope :upcoming, lambda {|datetime| {:conditions => ['started_at >= ?', Time.zone.parse(datetime).beginning_of_day]}}

  belongs_to :event_category, :validate => true
  belongs_to :library, :validate => true
  has_many :attachment_files, :as => :attachable
  has_many :picture_files, :as => :picture_attachable
  has_many :participates, :dependent => :destroy
  has_many :patrons, :through => :participates

  #acts_as_taggable_on :tags
  #acts_as_soft_deletable
  searchable do
    text :title, :note
    integer :library_id
    time :created_at
    time :updated_at
    time :started_at
    time :ended_at
  end
  #acts_as_solr :fields => [:title, :note, {:created_at => :date}, {:updated_at => :date}, {:started_at => :date}, {:ended_at => :date}], :auto_commit => false

  validates_presence_of :title, :library, :event_category
  validates_associated :library, :event_category

  cattr_accessor :per_page
  @@per_page = 10

  def before_save
    if self.started_at.blank?
      self.started_at = Time.zone.today.beginning_of_day
    end
    if self.ended_at.blank?
      self.ended_at = Time.zone.today.end_of_day
    end
  end

  def validate
    if self.started_at and self.ended_at
      if self.started_at >= self.ended_at
        errors.add(:started_at)
        errors.add(:ended_at)
      end
    end
  end

  def term
    title
  end

end
