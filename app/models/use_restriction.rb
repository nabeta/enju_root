# == Schema Information
#
# Table name: use_restrictions
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class UseRestriction < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions
end
