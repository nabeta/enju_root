class PatronType < ActiveRecord::Base
  include DisplayName
  has_many :patrons

  validates_presence_of :name

  acts_as_list

end
