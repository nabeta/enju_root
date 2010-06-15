class CirculationStatus < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  named_scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  before_validation :set_display_name, :on => :create

  acts_as_list

  def after_save
    Rails.cache.delete('CirculationStatus.available_for_checkout')
  end

  def after_destroy
    after_save
  end
end
