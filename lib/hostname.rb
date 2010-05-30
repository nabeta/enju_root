module Hostname
  def my_host?
    url= URI.parse(self)
    config_url = URI.parse(LibraryGroup.url)
    if url.host == config_url.host and url.port == config_url.port
      true
    else
      false
    end
  end
end

class String
  include Hostname
end
