# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://#{LIBRARY_WEB_HOSTNAME}"

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly', 
  #           :lastmod => Time.now, :host => default_host

  
  sitemap.add manifestations_path, :priority => 0.7, :changefreq => 'daily'

  Manifestation.find_each do |manifestation|
    sitemap.add manifestation_path(manifestation), :lastmod => manifestation.updated_at
  end

  Patron.find_each do |patron|
    sitemap.add patron_path(patron), :lastmod => patron.updated_at
  end

end
