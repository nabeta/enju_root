# -*- encoding: utf-8 -*-
class UserGroup < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :users
  #has_many :available_carrier_types
  #has_many :carrier_types, :through => :available_carrier_types, :order => :position
  has_many :lending_policies

  validates_numericality_of :valid_period_for_new_user, :greater_than_or_equal_to => 0

  def self.per_page
    10
  end
end
# == Schema Information
#
# Table name: user_groups
#
#  id                        :integer         not null, primary key
#  name                      :string(255)     not null
#  string                    :string(255)
#  display_name              :text
#  note                      :text
#  position                  :integer
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  deleted_at                :datetime
#  valid_period_for_new_user :integer         default(0), not null
#  expired_at                :datetime
#

