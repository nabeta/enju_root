class Subscribe < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :subscription, :counter_cache => true, :validate => true
  belongs_to :manifestation, :validate => true

  validates_associated :subscription, :manifestation
  validates_presence_of :subscription, :manifestation, :started_on, :ended_on
  validates_uniqueness_of :manifestation_id, :scope => :subscription_id
end
