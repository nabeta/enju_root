class FederatedCatalog < ActiveResource::Base
  USER = "next-l"
  PASS = "next-l"
  self.site = "http://#{USER}:#{PASS}@mwr.mediacom.keio.ac.jp:3010"
  self.logger = Logger.new($stderr)

  class FederatedCatalog::Manifestation < FederatedCatalog
  end
  class FederatedCatalog::Library < FederatedCatalog
  end
  class FederatedCatalog::Own < FederatedCatalog
  end
end
