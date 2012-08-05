# == Schema Information
#
# Table name: item_relationship_types
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ItemRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :item_relationships
end
