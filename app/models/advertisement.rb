class Advertisement < ActiveRecord::Base
  named_scope :current_ads, :conditions => ['started_at <= ? AND ended_at > ?', Time.zone.now, Time.zone.now], :order => :id
  named_scope :previous_ads, :conditions => ['ended_at <= ?', Time.zone.now], :order => :id

  has_many :advertises, :dependent => :destroy
  has_many :patrons, :through => :advertises

  validates_presence_of :title, :body, :started_at, :ended_at
  validates_length_of :url, :maximum => 255, :allow_nil => true

  acts_as_solr :fields => [:title, :body, {:url => :string}, :note, {:created_at => :date}, {:updated_at => :date}, {:started_at => :date}, {:ended_at => :date}], :auto_commit => false
  acts_as_soft_deletable

  def validate
    if self.started_at and self.ended_at
      if self.started_at > self.ended_at
        errors.add(:started_at)
        errors.add(:ended_at)
      end
    end
  end

  def self.pickup
    ids = Advertisement.current_ads.collect(&:id)
    Advertisement.find(ids.at(rand(ids.size)))
  end
end
