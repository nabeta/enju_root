class Language < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso1, :iso_639_1
  # alias_attribute :iso2, :iso_639_2
  # alias_attribute :iso3, :iso_639_3
  
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
end
