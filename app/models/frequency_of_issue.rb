class FrequencyOfIssue < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify
  has_many :expresssions
  validates_presence_of :name

  acts_as_list

end
