class WorkHasWork < ActiveRecord::Base
  include OnlyLibrarianCanModify
  belongs_to :from_work, :foreign_key => 'from_work_id', :class_name => 'Work'
  belongs_to :to_work, :foreign_key => 'to_work_id', :class_name => 'Work'
  belongs_to :work_relationship_type

  validates_presence_of :from_work, :to_work, :work_relationship_type
  validates_uniqueness_of :from_work_id, :scope => :to_work_id

  acts_as_list :scope => :from_work

  def before_update
    Work.find(from_work_id_was).send_later(:save_with_index)
    Work.find(to_work_id_was).send_later(:save_with_index!)
  end

  def after_save
    from_work.send_later(:save_with_index)
    to_work.send_later(:save_with_index!)
  end
end
