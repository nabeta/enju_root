require 'open-uri'
class BookmarkedResource < ActiveRecord::Base
  named_scope :manifestations, lambda {|manifestation_ids| {:conditions => {:manifestation_id => manifestation_ids}}}
  has_many :bookmarks, :dependent => :destroy, :include => :bookmarked_resource
  has_many :users, :through => :bookmarks, :conditions => 'users.deleted_at IS NULL'
  belongs_to :manifestation, :validate => true
  
  validates_associated :manifestation
  validates_presence_of :url, :manifestation
  validates_uniqueness_of :manifestation_id
  validates_length_of :url, :maximum => 255, :allow_nil => true

  cattr_reader :per_page
  @@per_page = 10

  attr_accessor :from_date
  attr_accessor :to_date

  # http://d.hatena.ne.jp/zariganitosh/20061120/1163998759
  def validate
    errors.add(:url, ('Invalid URL.')) unless (URI(read_attribute(:url)) rescue false)
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def bookmarked_count(from_date = Time.zone.now.beginning_of_day, to_date = 1.day.from_now.beginning_of_day)
    if from_date or to_date
      from_date = Time.zone.now.beginning_of_day if from_date.blank?
      to_date = 1.day.from_now.beginning_of_day if to_date.blank?
      self.bookmarks.find(:all, :conditions => ['created_at >= ? AND created_at < ?', from_date, to_date]).size
    else
      self.bookmarks.size
    end
  end

  def tags
    self.bookmarks.collect(&:tags).flatten
  end

end
