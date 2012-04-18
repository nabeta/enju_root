class WorkMerge < ActiveRecord::Base
  belongs_to :work, :validate => true
  belongs_to :work_merge_list, :validate => true
  validates_presence_of :work, :work_merge_list
  validates_associated :work, :work_merge_list

  def self.per_page
    10
  end
end
# == Schema Information
#
# Table name: work_merges
#
#  id                 :integer         not null, primary key
#  work_id            :integer         not null
#  work_merge_list_id :integer         not null
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

