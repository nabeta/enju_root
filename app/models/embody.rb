class Embody < ActiveRecord::Base
  belongs_to :expression
  belongs_to :manifestation

  validates_associated :expression, :manifestation
  validates_presence_of :expression_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :expression_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :expression

  def self.per_page
    10
  end

  def reindex
    expression.index
    manifestation.index
  end

end
# == Schema Information
#
# Table name: embodies
#
#  id               :integer         not null, primary key
#  expression_id    :integer         not null
#  manifestation_id :integer         not null
#  type             :string(255)
#  position         :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

