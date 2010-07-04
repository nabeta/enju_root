class NiiType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :manifestations

  def after_save
    Rails.cache.delete('NiiType.all')
  end

  def after_destroy
    after_save
  end
end
