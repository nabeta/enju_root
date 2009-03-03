class ClassificationType < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify
  has_many :classifications
  validates_presence_of :name

  acts_as_list

end
