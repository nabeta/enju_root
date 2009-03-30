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

  def rewrite_my_url
    if self.my_host?
      url= URI.parse(self)
      if url.host == BOOKMARK_HOSTNAME
        if url.port == LIBRARY_WEB_PORT_NUMBER
          url.port = BOOKMARK_PORT_NUMBER
        end
      else
        url.host = BOOKMARK_HOSTNAME
        url.port = BOOKMARK_PORT_NUMBER
      end
      url.normalize.to_s
    else
      self
    end
  end

  def rewrite_bookmark_url
    url = URI.parse(self)
    if url.host == BOOKMARK_HOSTNAME and url.port == BOOKMARK_PORT_NUMBER.to_i
      url.host = LIBRARY_WEB_HOSTNAME
      url.port = LIBRARY_WEB_PORT_NUMBER
    end
    url.normalize.to_s
  end
end
