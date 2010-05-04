class NewsPost < ActiveRecord::Base
  named_scope :published, :conditions => ['draft IS false']
  belongs_to :user
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true

  validates_presence_of :title, :body, :user_id
  validates_associated :user

  acts_as_list

  def self.per_page
    10
  end
end
