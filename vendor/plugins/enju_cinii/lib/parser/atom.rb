module Feedzirra
  
  module Parser
    # iTunes is Atom 2.0 + some apple extensions
    # Source: http://www.apple.com/itunes/whatson/podcasts/specs.html
    class OpenSearchAtom
      include SAXMachine
      include FeedUtilities

      element :title
      element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
      element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
      elements :entry, :as => :entries, :class => AtomEntry

      element :"opensearch:startIndex", :as => :start_index
      element :"opensearch:itemsPerPage", :as => :items_per_page
      element :"opensearch:totalResults", :as => :total_results

      def self.able_to_parse?(xml)
        xml =~ /xmlns:opensearch=\"http:\/\/a9.com\/-\/spec\/opensearch\/1.1\/\"/
      end

    end
    
  end
  
end
