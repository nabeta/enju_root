class PatronType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "patron_types.position"
  has_many :patrons

  before_destroy :check_deletable

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
