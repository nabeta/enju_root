class ManifestationHasManifestation < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_manifestation, :foreign_key => 'from_manifestation_id', :class_name => 'Manifestation'
  belongs_to :to_manifestation, :foreign_key => 'to_manifestation_id', :class_name => 'Manifestation'
  belongs_to :manifestation_relationship_type

  validates_presence_of :from_manifestation, :to_manifestation, :manifestation_relationship_type
  validates_uniqueness_of :from_manifestation_id, :scope => :to_manifestation_id

  acts_as_list :scope => :from_manifestation

  def before_save
    Manifestation.find(from_manifestation_id_was).send_later(:save_with_index)
    Manifestation.find(to_manifestation_id_was).send_later(:save_with_index!)
  end

  def after_save
    from_manifestation.send_later(:save_with_index)
    to_manifestation.send_later(:save_with_index!)
  end

end
