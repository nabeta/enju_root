# == Schema Information
#
# Table name: work_to_expression_rel_types
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class WorkToExpressionRelType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :reifies
end
