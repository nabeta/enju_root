module Feedzirra
  
  module Parser
    # iTunes is RSS 2.0 + some apple extensions
    # Source: http://www.apple.com/itunes/whatson/podcasts/specs.html
    class OpenSearchRSS
      include SAXMachine
      include FeedUtilities

      element :title
      element :link, :as => :url
      elements :item, :as => :entries, :class => RSSEntry

      element :"opensearch:startIndex", :as => :start_index
      element :"opensearch:itemsPerPage", :as => :items_per_page
      element :"opensearch:totalResults", :as => :total_results

      def self.able_to_parse?(xml)
        xml =~ /xmlns:opensearch=\"http:\/\/a9.com\/-\/spec\/opensearch\/1.1\/\"/
      end

    end
    
  end
  
end
