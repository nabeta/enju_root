# == Schema Information
#
# Table name: work_has_subjects
#
#  id           :integer          not null, primary key
#  subject_id   :integer
#  subject_type :string(255)
#  work_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class WorkHasSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :work

  validates_presence_of :work, :subject #, :subject_type
  validates_associated :work, :subject
  validates_uniqueness_of :subject_id, :scope => :work_id
  after_save :reindex
  after_destroy :reindex

  paginates_per 10

  def reindex
    work.index
    subject.index
  end
end
