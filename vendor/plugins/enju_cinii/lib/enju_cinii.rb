module EnjuCinii
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_cinii
      include EnjuCinii::InstanceMethods
      Atom::Feed.add_extension_namespace :opensearch, "http://a9.com/-/spec/opensearch/1.1/"
      Atom::Feed.element "opensearch:totalResults"
    end

    def search_cinii(query)
      url = "http://ci.nii.ac.jp/opensearch/search?q=#{URI.encode(query)}&format=atom"
      Atom::Feed.load_feed(URI.parse(url))
    end
  end

  module InstanceMethods
    def cinii_feed(page = 1, count = 10)
      start = (page - 1) * count + 1
      if self.respond_to?(:issn)
        url = "http://ci.nii.ac.jp/opensearch/search?issn=#{self.issn}&count=#{count}&start=#{start}&format=atom"
      end
      Atom::Feed.load_feed(URI.parse(url))
    end
  end
end
