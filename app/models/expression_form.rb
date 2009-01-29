class ExpressionForm < ActiveRecord::Base
  include DisplayName
  has_many :expressions

  validates_presence_of :name

  acts_as_list

end
