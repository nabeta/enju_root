class WorkHasWork < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :work_from_work, :foreign_key => 'from_work_id', :class_name => 'Work'
  belongs_to :work_to_work, :foreign_key => 'to_work_id', :class_name => 'Work'

  validates_uniqueness_of :from_work_id, :scope => :to_work_id
end
