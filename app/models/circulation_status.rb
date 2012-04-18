class CirculationStatus < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items
end
# == Schema Information
#
# Table name: circulation_statuses
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

