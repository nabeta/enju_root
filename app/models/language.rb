class Language < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso1, :iso_639_1
  # alias_attribute :iso2, :iso_639_2
  # alias_attribute :iso3, :iso_639_3
  
  # Validations
  validates_presence_of :name, :display_name
  acts_as_list

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete('Language.all')
    Rails.cache.delete('Language.available')
  end

  def self.available_languages
    #Rails.cache.fetch('Language.available_languages'){Language.all(:conditions => {:iso_639_1 => I18n.available_locales.map{|l| l.to_s}})}
    Language.all(:conditions => {:iso_639_1 => I18n.available_locales.map{|l| l.to_s}})
  end

  def before_validation_on_create
    self.display_name = self.name if display_name.blank?
  end
end
