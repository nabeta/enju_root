class Subscribe < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :subscription, :counter_cache => true, :validate => true
  belongs_to :work, :validate => true

  validates_associated :subscription, :work
  validates_presence_of :subscription, :work, :started_on, :ended_on
  validates_uniqueness_of :work_id, :scope => :subscription_id
end
