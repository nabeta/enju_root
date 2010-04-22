class PatronType < ActiveRecord::Base
  default_scope :order => "patron_types.position"
  has_many :patrons

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name

  acts_as_list

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end

  def after_save
    Rails.cache.delete('PatronType.all')
  end

  def after_destroy
    after_save
  end
end
