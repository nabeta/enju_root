class LendingPolicy < ActiveRecord::Base
  include OnlyAdministratorCanModify

  belongs_to :item
  belongs_to :user_group

  validates_presence_of :item, :user_group
  validates_uniqueness_of :user_group_id, :scope => :item_id

  @@per_page = 10
  cattr_accessor :per_page

  acts_as_list :scope => :item_id
end
