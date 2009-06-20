module EnjuWorldcat
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_worldcat
      include EnjuWorldcat::InstanceMethods
    end

    def search_worldcat(options = {})
      options = {:format => 'atom', :page => 1, :per_page => 10}.merge(options)
      client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
      if options[:page].to_i < 1
        options[:page] = 1
      end
      startrecord = options[:page] * options[:per_page]
      response = client.OpenSearch(:q => options[:query], :format => options[:format], :start => startrecord, :count => options[:per_page], :cformat => 'all')
    rescue
      nil
    end

  end
  
  module InstanceMethods
    @client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
    def worldcat_record
      client = WCAPI::Client.new(:wskey => WORLDCAT_API_KEY)
      client.GetRecord(:type => 'isbn', :id => self.isbn).record
    rescue
      nil
    end

    def worldcat_locations
    end

    def worldcat_citation
      @client.GetCitation(:type => 'isbn', :id => self.isbn)
    end
  end
end
