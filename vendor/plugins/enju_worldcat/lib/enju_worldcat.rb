module EnjuWorldcat
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    @@client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
    def enju_worldcat
      include EnjuWorldcat::InstanceMethods
    end

    def search_worldcat(options = {})
      options = {:format => 'atom', :page => 1, :per_page => 10}.merge(options)
      #client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
      if options[:page].to_i < 1
        options[:page] = 1
      end
      startrecord = options[:page] * options[:per_page]
      response = @@client.OpenSearch(:q => options[:query], :format => options[:format], :start => startrecord, :count => options[:per_page], :cformat => 'all')
    rescue
      nil
    end

    def search_worldcat_by_isbn(isbn)
      @@client.GetRecord(:type => 'isbn', :id => isbn).record
    end
  end
  
  module InstanceMethods
    @@client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
    def worldcat_record
      @@client.GetRecord(:type => 'isbn', :id => self.isbn).record
    rescue
      nil
    end

    def worldcat_locations
    end

    def worldcat_citation
      @@client.GetCitation(:type => 'isbn', :id => self.isbn)
    end

    def xisbn_manifestations
      doc = REXML::Document.new open("http://xisbn.worldcat.org/webservices/xid/isbn/#{self.isbn}?method=getEditions&format=xml&fl=*")
      isbn_array = REXML::XPath.match(doc, '/rsp/isbn/')
      manifestations = []
      isbn_array.each do |isbn|
        manifestation = {}
        manifestation[:isbn] = isbn.text
        manifestation[:title] = isbn.attribute('title').to_s
        manifestation[:author] = isbn.attribute('author').to_s
        manifestation[:publisher] = isbn.attribute('publisher').to_s
        manifestation[:year] = isbn.attribute('year').to_s
        manifestation[:lccn] = isbn.attribute('lccn').to_s
        manifestations << manifestation if manifestation[:isbn] != self.isbn
      end
      return manifestations
    end
  end
end
