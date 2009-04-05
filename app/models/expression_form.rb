class ExpressionForm < ActiveRecord::Base
  include DisplayName
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  has_many :expressions

  validates_presence_of :name

  acts_as_list

end
