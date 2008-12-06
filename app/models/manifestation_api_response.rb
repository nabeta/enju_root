class ManifestationApiResponse < ActiveRecord::Base
  belongs_to :manifestation, :validate => true
  validates_associated :manifestation
  validates_presence_of :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :type
end
