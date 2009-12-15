class SeriesStatement < ActiveRecord::Base
  include LibrarianOwnerRequired
  has_many :manifestations
  validates_presence_of :title
  acts_as_list

  def last_issue
    manifestations.find(:first, :conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC')
  end

end
