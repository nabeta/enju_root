class PatronType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "patron_types.position"
  has_many :patrons

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  before_validation :set_display_name, :on => :create
  before_destroy :check_deletable

  acts_as_list

  def after_save
    Rails.cache.delete('PatronType.all')
  end

  def after_destroy
    after_save
  end

  def deletable?
    return true if patrons.first
    false
  end
end
