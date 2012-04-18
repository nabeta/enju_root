class Produce < ActiveRecord::Base
  belongs_to :patron
  belongs_to :manifestation

  validates_associated :patron, :manifestation
  validates_presence_of :patron_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :patron_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :manifestation

  def self.per_page
    10
  end

  def reindex
    patron.index
    manifestation.index
  end

end
# == Schema Information
#
# Table name: produces
#
#  id               :integer         not null, primary key
#  patron_id        :integer         not null
#  manifestation_id :integer         not null
#  position         :integer
#  type             :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  produce_type_id  :integer
#

