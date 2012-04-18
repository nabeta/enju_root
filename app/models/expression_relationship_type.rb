class ExpressionRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :expression_relationships
end
# == Schema Information
#
# Table name: expression_relationship_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

