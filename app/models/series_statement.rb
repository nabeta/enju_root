class SeriesStatement < ActiveRecord::Base
  include LibrarianOwnerRequired
  has_many :manifestations
  validates_presence_of :title
end
