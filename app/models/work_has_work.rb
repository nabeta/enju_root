class WorkHasWork < ActiveRecord::Base
  belongs_to :from_work, :foreign_key => 'from_work_id', :class_name => 'Work'
  belongs_to :to_work, :foreign_key => 'to_work_id', :class_name => 'Work'
  belongs_to :work_relationship_type

  validates_presence_of :from_work, :to_work, :work_relationship_type
  validates_uniqueness_of :from_work_id, :scope => :to_work_id

  acts_as_list :scope => :from_work

  def before_update
    Work.find(from_work_id_was).index
    Work.find(to_work_id_was).index
  end

  def after_save
    from_work.index
    to_work.index
  end

  def after_destroy
    after_save
  end
end
