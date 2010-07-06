# -*- encoding: utf-8 -*-
class LibraryGroup < ActiveRecord::Base
  #include Singleton
  #include Configurator

  has_many :libraries
  has_many :search_engines
  has_many :news_feeds
  belongs_to :country

  validates_presence_of :name, :display_name, :email

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def before_validation
    self.display_name = self.name if display_name.blank?
  end

  def expire_cache
    Rails.cache.delete("LibraryGroup:#{id}")
  end

  def self.site_config
    #Rails.cache.fetch('LibraryGroup:1'){LibraryGroup.find(1)}
    LibraryGroup.find(1)
  end

  def self.url
    URI.parse("http://#{LIBRARY_WEB_HOSTNAME}:#{LIBRARY_WEB_PORT_NUMBER}").normalize.to_s
  end

  def config?
    true if self == LibraryGroup.site_config
  end

  def real_libraries
    # 物理的な図書館 = IDが1以外
    self.libraries.all(:conditions => ['id != 1'])
  end

  def network_access_allowed?(ip_address, options = {})
    options = {:network_type => 'lan'}.merge(options)
    client_ip = IPAddr.new(ip_address)
    case options[:network_type]
    when 'admin'
      allowed_networks = self.admin_networks.to_s.split
    else
      allowed_networks = self.my_networks.to_s.split
    end
    allowed_networks.each do |allowed_network|
      network = IPAddr.new(allowed_network)
      return true if network.include?(client_ip)
    end
    false
  rescue ArgumentError
    nil
  end

end
