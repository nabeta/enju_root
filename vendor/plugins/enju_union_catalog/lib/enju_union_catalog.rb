class UnionCatalog < ActiveResource::Base
  self.site = 'http://mwr.mediacom.keio.ac.jp:3010'
  self.logger = Logger.new($stderr)

  class UnionCatalog::Manifestation < UnionCatalog
  end
  class UnionCatalog::Library < UnionCatalog
  end
  class UnionCatalog::Own < UnionCatalog
  end
end
