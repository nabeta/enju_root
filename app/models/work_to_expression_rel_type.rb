class WorkToExpressionRelType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :reifies
end
