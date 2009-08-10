class CirculationStatus < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  named_scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name

  acts_as_list

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end

  def after_save
    Rails.cache.delete('CirculationStatus.available_for_checkout')
  end

end
