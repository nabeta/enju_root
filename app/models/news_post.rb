class NewsPost < ActiveRecord::Base
  named_scope :published, :conditions => ['draft IS false']
  belongs_to :user

  validates_presence_of :title, :body, :user_id
  validates_associated :user

  acts_as_list
end
