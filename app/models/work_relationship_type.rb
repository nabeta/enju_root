# == Schema Information
#
# Table name: work_relationship_types
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class WorkRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :work_relationships
end
