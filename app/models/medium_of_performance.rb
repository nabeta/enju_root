# == Schema Information
#
# Table name: medium_of_performances
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MediumOfPerformance < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :works
end
