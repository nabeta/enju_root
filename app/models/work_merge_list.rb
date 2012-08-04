# == Schema Information
#
# Table name: work_merge_lists
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WorkMergeList < ActiveRecord::Base
  has_many :work_merges, :dependent => :destroy
  has_many :works, :through => :work_merges
  validates_presence_of :title

  paginates_per 10

  def merge_works(selected_work)
    self.works.each do |work|
      Create.update_all(['work_id = ?', selected_work.id], ['work_id = ?', work.id])
      Reify.update_all(['work_id = ?', selected_work.id], ['work_id = ?', work.id])
      work.destroy unless work == selected_work
    end
  end
end
