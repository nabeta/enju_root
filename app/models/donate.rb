class Donate < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :patron, :validate => true
  belongs_to :item, :validate => true
  validates_associated :patron, :item
  validates_presence_of :patron, :item

  cattr_reader :per_page
  @@per_page = 10
end
