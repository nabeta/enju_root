class SubjectType < ActiveRecord::Base
  include DisplayName
  has_many :subject_type
  validates_presence_of :name

  acts_as_list

end
