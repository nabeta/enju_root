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

module EnjuUnionCatalog
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_union_catalog
      include EnjuUnionCatalog::InstanceMethods
    end
  end

  module InstanceMethods
    def post_to_union_catalog
      return false if self.item_identifier.blank?
      self.reload
      local_library = self.shelf.library
      library_url = URI.parse("#{LibraryGroup.url}libraries/#{local_library.short_name}").normalize.to_s
      manifestation_url = URI.parse("#{LibraryGroup.url}manifestations/#{self.manifestation.id}").normalize.to_s
      resource = UnionCatalog::Manifestation.find(:first, :params => {:isbn => self.manifestation.isbn})
      if resource.nil?
        #resource = UnionCatalog::Manifestation.create(:title => self.manifestation.original_title, :library_url => library_url, :author => self.manifestation.authors.collect(&:full_name).join(" / "), :publisher => self.manifestation.publishers.collect(&:full_name).join(" / "), :isbn => self.manifestation.isbn, :local_manifestation_id => self.manifestation.id)
        resource = UnionCatalog::Manifestation.create(:title => self.manifestation.original_title, :library_url => library_url, :author => self.manifestation.authors.collect(&:full_name).join(" / "), :publisher => self.manifestation.publishers.collect(&:full_name).join(" / "), :isbn => self.manifestation.isbn, :manifestation_url => manifestation_url)
      end

      library = UnionCatalog::Library.find(:first, :params => {:url => library_url})
      if library.nil?
        library = UnionCatalog::Library.create(:name => local_library.name, :url => library_url, :zip_code => local_library.postal_code, :address => local_library.address, :lat => local_library.geocode.latitude, :lng => local_library.geocode.longitude)
      end

      resource_url = URI.parse("http://#{UnionCatalog.site.host}:#{UnionCatalog.site.port}/manifestations/#{resource.id}").normalize.to_s
      #UnionCatalog::Own.create(:manifestation_id => resource.id, :library_id => library.id, :url => manifestation_url, :library_url => library_url)
      UnionCatalog::Own.create(:manifestation_url => resource_url, :library_url => library_url)
    end

    def update_union_catalog
      return false if self.item_identifier.blank?
      local_library = self.shelf.library
      library_url = URI.parse("#{LibraryGroup.url}libraries/#{local_library.short_name}").normalize.to_s
      manifestation_url = URI.parse("#{LibraryGroup.url}manifestations/#{self.manifestation.id}").normalize.to_s
      own = UnionCatalog::Own.find(:first, :params => {:url => manifestation_url, :library_url => library_url})
      own.library_url = library_url
      own.url = manifestation_url
      own.save
    end

    def remove_from_union_catalog
      return false if self.item_identifier.blank?
      manifestation_url = URI.parse("#{LibraryGroup.url}manifestations/#{self.manifestation.id}").normalize.to_s
      own = UnionCatalog::Own.find(:first, :params => {:url => manifestation_url})
      own.destroy
    end

  end
end
