class WorkHasWork < ActiveRecord::Base
  belongs_to :work_from_work, :foreign_key => 'from_work_id', :class_name => 'Work'
  belongs_to :work_to_work, :foreign_key => 'to_work_id', :class_name => 'Work'
end
