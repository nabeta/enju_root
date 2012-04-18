class ItemHasUseRestriction < ActiveRecord::Base
  belongs_to :item, :validate => true
  belongs_to :use_restriction, :validate => true

  def self.per_page
    10
  end

  validates_associated :item, :use_restriction
  validates_presence_of :item, :use_restriction
end
# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :integer         not null, primary key
#  item_id            :integer         not null
#  use_restriction_id :integer         not null
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

