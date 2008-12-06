class Subscribe < ActiveRecord::Base
  belongs_to :subscription, :counter_cache => true, :validate => true
  belongs_to :expression, :validate => true

  validates_associated :subscription, :expression
  validates_presence_of :subscription, :expression, :start_on, :end_on
  validates_uniqueness_of :expression_id, :scope => :subscription_id
end
