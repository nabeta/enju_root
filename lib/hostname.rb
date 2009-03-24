class String
  def my_host?
    url= URI.parse(self)
    config_url = URI.parse(LibraryGroup.url)
    if url.host == config_url.host and url.port == config_url.port
      true
    else
      false
    end
  end

  def rewrite_my_host
    if self.my_host?
      url= URI.parse(self)
      if url.host == "localhost"
        if url.port == LIBRARY_WEB_PORT_NUMBER
          url.port = "3001" # TODO: 3000番で動かしていることを前提としない
        end
      else
        url.host = "localhost"
        url.port = "3001"
      end
      url.normalize.to_s
    else
      self
    end
  end
end
