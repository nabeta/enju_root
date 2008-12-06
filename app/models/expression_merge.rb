class ExpressionMerge < ActiveRecord::Base
  belongs_to :expression, :validate =>true
  belongs_to :expression_merge_list, :validate => true
  validates_presence_of :expression, :expression_merge_list
  validates_associated :expression, :expression_merge_list
end
