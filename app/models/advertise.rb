class Advertise < ActiveRecord::Base
  belongs_to :advertisement, :validate => true
  belongs_to :patron, :validate => true

  validates_associated :advertisement, :patron
  validates_presence_of :advertisement_id, :patron_id
  validates_uniqueness_of :patron_id, :scope => :advertisement_id

  acts_as_list :scope => :advertisement_id

  @@per_page = 10
  cattr_reader :per_page
end
