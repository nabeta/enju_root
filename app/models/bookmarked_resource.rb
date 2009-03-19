require 'open-uri'
class BookmarkedResource < ActiveRecord::Base
  include OnlyLibrarianCanModify
  named_scope :manifestations, lambda {|manifestation_ids| {:conditions => {:manifestation_id => manifestation_ids}}}
  has_many :bookmarks, :dependent => :destroy, :include => :tags
  has_many :users, :through => :bookmarks
  belongs_to :manifestation, :validate => true
  
  validates_associated :manifestation
  validates_presence_of :title, :url, :manifestation
  validates_uniqueness_of :manifestation_id
  validates_length_of :url, :maximum => 255, :allow_nil => true

  cattr_accessor :per_page
  @@per_page = 10

  attr_accessor :start_date
  attr_accessor :end_date

  # http://d.hatena.ne.jp/zariganitosh/20061120/1163998759
  def validate
    errors.add(:url, ('Invalid URL.')) unless (URI(read_attribute(:url)) rescue false)
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def bookmarked_count(start_date = Time.zone.now.beginning_of_day, end_date = 1.day.from_now.beginning_of_day)
    if start_date or end_date
      start_date = Time.zone.now.beginning_of_day if start_date.blank?
      end_date = 1.day.from_now.beginning_of_day if end_date.blank?
      self.bookmarks.find(:all, :conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]).size
    else
      self.bookmarks.size
    end
  end

  def tags
    self.bookmarks.collect(&:tags).flatten
  end

end
