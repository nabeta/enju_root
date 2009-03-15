class WorkMerge < ActiveRecord::Base
  include LibrarianRequired
  belongs_to :work, :validate => true
  belongs_to :work_merge_list, :validate => true
  validates_presence_of :work, :work_merge_list
  validates_associated :work, :work_merge_list

  cattr_accessor :per_page
  @@per_page = 10
end
