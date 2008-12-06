class WorkForm < ActiveRecord::Base
  include DisplayName
  has_many :works
  validates_presence_of :name

  acts_as_list

end
