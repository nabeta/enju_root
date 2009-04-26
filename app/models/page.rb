class Page
  def self.get_screen_shot(url)
    thumb = APICache.get(url)
  rescue
    nil
  end
end
