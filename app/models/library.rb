require 'mathn'
class Library < ActiveRecord::Base
  include DisplayName
  named_scope :physicals, :conditions => ['id != 1'], :order => :position
  has_many :shelves, :order => "shelves.position", :conditions => "shelves.deleted_at IS NULL"
  belongs_to :library_group, :validate => true
  has_many :events, :conditions => "events.deleted_at IS NULL", :include => :event_category
  belongs_to :patron, :validate => true
  has_many :inter_library_loans, :foreign_key => 'borrowing_library_id', :conditions => 'inter_library_loans.deleted_at IS NULL'
  has_many :users, :conditions => 'users.deleted_at IS NULL'

  acts_as_list
  acts_as_paranoid

  validates_associated :library_group, :patron
  validates_presence_of :name, :short_name, :short_display_name, :library_group, :patron
  validates_uniqueness_of :name, :short_name, :short_display_name
  validates_format_of :short_name, :with => /^[a-z][0-9a-z]{2,254}$/

  cattr_reader :per_page
  @@per_page = 10

  before_save :geocode_address

  def closed?(date)
    events.closing_days.collect{|c| c.started_at.beginning_of_day}.include?(date.beginning_of_day)
  end

  def web?
    return true if self.id == 1
    false
  end

  private

  def geocode_address
    if self.address
      geo = Geocoding::get(self.address)
      self.lat, self.lng = geo[0].latitude, geo[0].longitude if geo.status == Geocoding::GEO_SUCCESS
    end
  end
end
