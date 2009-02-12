class SubjectType < ActiveRecord::Base
  include DisplayName
  has_many :subjects

  validates_presence_of :name

  acts_as_list

end
