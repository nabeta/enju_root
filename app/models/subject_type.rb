class SubjectType < ActiveRecord::Base
  include DisplayName
  include AdministratorRequired

  default_scope :order => "position"
  has_many :subjects

  validates_presence_of :name

  acts_as_list

end
