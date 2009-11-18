class UnionCatalog < ActiveResource::Base
  self.site = 'http://mwr.mediacom.keio.ac.jp:3010'
  self.logger = Logger.new($stderr)

  class UnionCatalog::Patron < UnionCatalog
  end
  class UnionCatalog::Work < UnionCatalog
  end
  class UnionCatalog::Expression < UnionCatalog
  end
  class UnionCatalog::Manifestation < UnionCatalog
  end
  class UnionCatalog::Item < UnionCatalog
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
      manifestation = UnionCatalog::Manifestation.find(:first, :params => {:isbn => self.manifestation.isbn}) rescue nil
      if manifestation.nil?
        #resource = UnionCatalog::Manifestation.create(:title => self.manifestation.original_title, :library_url => library_url, :author => self.manifestation.authors.collect(&:full_name).join(" / "), :publisher => self.manifestation.publishers.collect(&:full_name).join(" / "), :isbn => self.manifestation.isbn, :local_manifestation_id => self.manifestation.id)
        work = UnionCatalog::Work.create(:original_title => self.manifestation.original_title)
        expression = UnionCatalog::Expression.create(:original_title => self.manifestation.original_title, :new_work_id => work.id)
        manifestation = UnionCatalog::Manifestation.create(:original_title => self.manifestation.original_title, :isbn => self.manifestation.isbn, :new_expression_id => expression.id)
      end
      item = UnionCatalog::Item.create(:item_identifier => self.item_identifier, :library_url => self.library_url, :new_manifestation_id => manifestation.id, :local_url => self.manifestation_url)

      #library = UnionCatalog::Library.find(:first, :params => {:url => library_url})
      #if library.nil?
      #  library = UnionCatalog::Library.create(:name => local_library.name, :url => library_url, :zip_code => local_library.postal_code, :address => local_library.address, :lat => local_library.geocode.latitude, :lng => local_library.geocode.longitude)
      #end

      manifestation_url = URI.parse("http://#{UnionCatalog.site.host}:#{UnionCatalog.site.port}/manifestations/#{manifestation.id}").normalize.to_s
      #UnionCatalog::Own.create(:manifestation_id => resource.id, :library_id => library.id, :url => manifestation_url, :library_url => library_url)
    end

    def update_union_catalog(old_url)
      return false if self.item_identifier.blank?
      own = UnionCatalog::Own.find(:first, :params => {:url => old_url})
      own.url = self.manifestation_url
      own.save
    end

    def remove_from_union_catalog
      return false if self.item_identifier.blank?
      own = UnionCatalog::Own.find(:first, :params => {:url => self.manifestation_url})
      own.destroy
    end

  end
end
