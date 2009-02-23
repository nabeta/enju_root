class RequestStatusType < ActiveRecord::Base
  include DisplayName
  include AdministratorRequired
  has_many :reserves

  validates_presence_of :name

  acts_as_list

end
