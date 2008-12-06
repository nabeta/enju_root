class ExpressionForm < ActiveRecord::Base
  include DisplayName
  has_many :expressions, :conditions => 'expressions.deleted_at IS NULL'

  validates_presence_of :name

  acts_as_list

end
