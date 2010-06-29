class ContentType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :expressions

  def after_save
    Rails.cache.delete('ContentType.all')
  end

  def after_destroy
    after_save
  end
end
