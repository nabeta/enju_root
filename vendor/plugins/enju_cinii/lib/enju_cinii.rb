module EnjuCinii
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_cinii
      include EnjuCinii::InstanceMethods
    end

    def search_cinii(query, format = 'atom')
      engine = OpenSearch::OpenSearch.new('http://ci.nii.ac.jp/opensearch/description.xml')
      case format
      when 'atom'
        type = 'application/atom+xml'
        Feedzirra::Feed.add_feed_class(Feedzirra::Parser::OpenSearchAtom)
      when 'rss'
        type = 'application/rdf+xml'
        Feedzirra::Feed.add_feed_class(Feedzirra::Parser::OpenSearchRSS)
      end
      Feedzirra::Feed.parse(engine.search(query, type))
    end
  end

  module InstanceMethods
  end
end
