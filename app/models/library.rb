# -*- encoding: utf-8 -*-
require 'mathn'
class Library < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => 'position'
  named_scope :physicals, :conditions => ['id != 1']
  has_many :shelves, :order => 'shelves.position'
  belongs_to :library_group, :validate => true
  has_many :events, :include => :event_category
  #belongs_to :holding_patron, :polymorphic => true, :validate => true
  belongs_to :patron, :validate => true
  has_many :inter_library_loans, :foreign_key => 'borrowing_library_id'
  has_many :users

  acts_as_list
  #acts_as_soft_deletable
  has_friendly_id :name
  acts_as_geocodable

  searchable do
    text :name, :display_name, :note, :address
    time :created_at
    time :updated_at
  end

  #validates_associated :library_group, :holding_patron
  validates_associated :library_group, :patron
  validates_presence_of :name, :display_name, :short_display_name, :library_group, :patron
  validates_uniqueness_of :name, :short_display_name
  validates_format_of :name, :with => /^[a-z][0-9a-z]{2,254}$/

  cattr_accessor :per_page
  @@per_page = 10

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete("Library:#{id}")
    Rails.cache.delete('Library.all')
  end

  def before_validation
    self.display_name = self.name if display_name.blank?
  end

  def closed?(date)
    events.closing_days.collect{|c| c.start_at.beginning_of_day}.include?(date.beginning_of_day)
  end

  def web?
    return true if self.id == 1
    false
  end

  def self.web
    Rails.cache.fetch("Library:1"){Library.find(1)}
  end

  def address
    self.region.to_s + self.locality.to_s + " " + self.street.to_s
  rescue
    nil
  end

  def is_deletable_by(user, parent = nil)
    raise if self.id == 1
    true if user.has_role?('Administrator')
  rescue
    false
  end

end
