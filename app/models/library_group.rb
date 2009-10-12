# -*- encoding: utf-8 -*-
class LibraryGroup < ActiveRecord::Base
  #include Singleton
  include OnlyAdministratorCanModify
  #include Configurator

  has_many :libraries
  has_many :search_engines
  has_many :news_feeds

  validates_presence_of :name, :display_name, :email

  def after_save
    expire_cache
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete("LibraryGroup:#{id}")
  end

  def self.site_config
    Rails.cache.fetch('LibraryGroup:1'){LibraryGroup.find(1)}
  end

  def self.url
    URI.parse("http://#{LIBRARY_WEB_HOSTNAME}:#{LIBRARY_WEB_PORT_NUMBER}").normalize.to_s
  end

  def config?
    true if self == LibraryGroup.site_config
  end

  def physical_libraries
    # 物理的な図書館 = IDが1以外
    self.libraries.find(:all, :conditions => ['id != 1'])
  end

  def my_networks?(ip_address)
    client_ip = IPAddr.new(ip_address)
    allowed_networks = self.my_networks.to_s.split
    allowed_networks.each do |allowed_network|
      begin
        network = IPAddr.new(allowed_network)
        return true if network.include?(client_ip)
      rescue
        nil
      end
    end
    return false
  end

  def is_deletable_by(user, parent = nil)
    raise if self.config?
    true if user.has_role?('Administrator')
  rescue
    false
  end

  def self.solr_reindex(num = 500)
    Patron.reindex(:batch_size => num)
    Work.reindex(:batch_size => num)
    Expression.reindex(:batch_size => num)
    Manifestation.reindex(:batch_size => num)
    logger.info "#{Time.zone.now} optimized!"
  rescue StandardError, Timeout::Error
    logger.info "#{Time.zone.now} optimization failed!"
  end

end
