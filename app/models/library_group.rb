class LibraryGroup < ActiveRecord::Base
  include Singleton
  include DisplayName
  include OnlyAdministratorCanModify
  include Configurator
  has_many :libraries, :order => 'position'
  has_many :search_engines
  has_many :news_feeds

  validates_presence_of :name, :short_name, :email

  def self.config
    LibraryGroup.find(1)
  end

  def self.url
    URI.parse("http://#{LIBRARY_WEB_HOSTNAME}:#{LIBRARY_WEB_PORT_NUMBER}").normalize.to_s
  end

  def config?
    true if self == LibraryGroup.config
  end

  def physical_libraries
    # 物理的な図書館 = IDが1以外
    self.libraries.find(:all, :conditions => ['id != 1'], :order => :position)
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
end
