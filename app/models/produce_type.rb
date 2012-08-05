# == Schema Information
#
# Table name: produce_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ProduceType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
end
