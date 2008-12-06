class ItemHasUseRestriction < ActiveRecord::Base
  belongs_to :item, :validate => true
  belongs_to :use_restriction, :validate => true
  cattr_reader :per_page
  @@per_page = 10

  validates_associated :item, :use_restriction
  validates_presence_of :item, :use_restriction
end
