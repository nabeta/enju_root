class RequestStatusType < ActiveRecord::Base
  include DisplayName
  has_many :reserves

  validates_presence_of :name

  acts_as_list

end
