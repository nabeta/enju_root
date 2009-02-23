class ManifestationHasManifestation < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :manifestation_from_manifestation, :foreign_key => 'from_manifestation_id', :class_name => 'Manifestation'
  belongs_to :manifestation_to_manifestation, :foreign_key => 'to_manifestation_id', :class_name => 'Manifestation'

  validates_uniqueness_of :from_manifestation_id, :scope => :to_manifestation_id
end
