# == Schema Information
#
# Table name: expression_merges
#
#  id                       :integer          not null, primary key
#  expression_id            :integer          not null
#  expression_merge_list_id :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ExpressionMerge < ActiveRecord::Base
  belongs_to :expression, :validate => true
  belongs_to :expression_merge_list, :validate => true
  validates_presence_of :expression, :expression_merge_list
  validates_associated :expression, :expression_merge_list

  paginates_per 10
end
