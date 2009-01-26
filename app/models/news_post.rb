class NewsPost < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title, :body, :user_id
  validates_associated :user

  acts_as_list
end
