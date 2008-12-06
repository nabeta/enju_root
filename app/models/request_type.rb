class RequestType < ActiveRecord::Base
  include DisplayName
  validates_presence_of :name

  acts_as_list

end
