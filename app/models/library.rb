# -*- encoding: utf-8 -*-
class Library < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'libraries.position'
  scope :real, where('id != 1')
  has_many :shelves, :order => 'shelves.position'
  belongs_to :library_group, :validate => true
  has_many :events, :include => :event_category
  #belongs_to :holding_patron, :polymorphic => true, :validate => true
  belongs_to :patron #, :validate => true
  has_many :inter_library_loans, :foreign_key => 'borrowing_library_id'
  has_many :users
  belongs_to :country

  extend FriendlyId
  friendly_id :name
  geocoded_by :address
  #enju_calil_library

  searchable do
    text :name, :display_name, :note, :address
    time :created_at
    time :updated_at
    integer :position
  end

  #validates_associated :library_group, :holding_patron
  validates_associated :library_group, :patron
  validates_presence_of :short_display_name, :library_group, :patron
  validates_uniqueness_of :short_display_name, :case_sensitive => false
  validates :display_name, :uniqueness => true
  validates :name, :format => {:with => /^[a-z][0-9a-z]{2,254}$/}
  before_validation :set_patron, :on => :create
  #before_save :set_calil_neighborhood_library
  after_validation :geocode, :if => :address_changed?
  after_create :create_shelf
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  def self.per_page
    10
  end

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('library_all'){Library.all}
    else
      Library.all
    end
  end

  def clear_all_cache
    Rails.cache.delete('library_all')
  end

  def set_patron
    self.patron = Patron.new(
      :full_name => self.name
    )
  end

  def create_shelf
    Shelf.create!(:name => "#{self.name}_default", :library => self)
  end

  def closed?(date)
    events.closing_days.collect{|c| c.start_at.beginning_of_day}.include?(date.beginning_of_day)
  end

  def web?
    return true if self.id == 1
    false
  end

  def self.web
    Library.find(1)
  end

  def address(locale = I18n.locale)
    case locale.to_sym
    when :ja
      "#{self.region.to_s.localize(locale)}#{self.locality.to_s.localize(locale)}#{self.street.to_s.localize(locale)}"
    else
      "#{self.street.to_s.localize(locale)} #{self.locality.to_s.localize(locale)} #{self.region.to_s.localize(locale)}"
    end
  rescue
    nil
  end

  def address_changed?
    return true if region_changed? or locality_changed? or street_changed?
    false
  end
end
