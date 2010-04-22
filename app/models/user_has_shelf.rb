class UserHasShelf < ActiveRecord::Base
  belongs_to :user
  belongs_to :shelf

  validates_associated :user, :shelf
  validates_presence_of :user_id, :shelf_id

  acts_as_list :scope => :user_id
end
