class Realize < ActiveRecord::Base
  attr_accessible :expression_id, :person_id
  belongs_to :expression
  belongs_to :person
  validates_uniqueness_of :expression_id, :scope => :work_id
end
