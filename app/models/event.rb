# -*- encoding: utf-8 -*-
class Event < ActiveRecord::Base
  include OnlyLibrarianCanModify

  named_scope :closing_days, :include => :event_category, :conditions => ['event_categories.name = ?', 'closed']
  named_scope :on, lambda {|datetime| {:conditions => ['start_at >= ? AND end_at < ?', Time.zone.parse(datetime).beginning_of_day, Time.zone.parse(datetime).tomorrow.beginning_of_day + 1]}}
  named_scope :past, lambda {|datetime| {:conditions => ['end_at <= ?', Time.zone.parse(datetime).beginning_of_day]}}
  named_scope :upcoming, lambda {|datetime| {:conditions => ['start_at >= ?', Time.zone.parse(datetime).beginning_of_day]}}
  named_scope :at, lambda {|library| {:conditions => {:library_id => library.id}}}

  belongs_to :event_category, :validate => true
  belongs_to :library, :validate => true
  has_many :attachment_files, :as => :attachable
  has_many :picture_files, :as => :picture_attachable
  has_many :participates, :dependent => :destroy
  has_many :patrons, :through => :participates

  #acts_as_taggable_on :tags
  #acts_as_soft_deletable
  has_event_calendar

  searchable do
    text :title, :note
    integer :library_id
    time :created_at
    time :updated_at
    time :start_at
    time :end_at
  end

  validates_presence_of :title, :library_id, :event_category_id
  validates_associated :library, :event_category

  cattr_accessor :per_page
  @@per_page = 10

  def before_save
    if self.start_at.blank?
      self.start_at = Time.zone.today.beginning_of_day
    end
    if self.end_at.blank?
      self.end_at = Time.zone.today.end_of_day
    end
  end

  def validate
    if self.start_at and self.end_at
      if self.start_at >= self.end_at
        errors.add(:start_at)
        errors.add(:end_at)
      end
    end
  end

  def name
    title
  end

end
