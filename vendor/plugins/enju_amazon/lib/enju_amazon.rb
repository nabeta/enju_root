module EnjuAmazon
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_amazon
      include EnjuAmazon::InstanceMethods
    end
  end

  module InstanceMethods
    def access_amazon(response = nil)
      # キャッシュがない場合
      #if self.manifestation_api_response.blank?
        amazon_url = ""
        #@isbn = @resource.searchable.isbn.sub("urn:isbn:", "") rescue ""
        unless self.isbn.blank?
          #@amazon_url = "http://#{@library_group.amazon_host}/onca/xml?Service=AWSECommerceService&SubscriptionId=#{AMAZON_ACCESS_KEY}&Operation=ItemLookup&IdType=ASIN&ItemId=#{@resource.searchable.isbn}&ResponseGroup=Images"
          amazon_url = "http://#{AMAZON_AWS_HOSTNAME}/onca/xml?Service=AWSECommerceService&SubscriptionId=#{AMAZON_ACCESS_KEY}&Operation=ItemLookup&SearchIndex=Books&IdType=ISBN&ItemId=#{isbn}&ResponseGroup=Images,Reviews"
          #last_response = self.manifestation_api_response
          #unless last_response.nil?
          #  # 1 request per 1 second
          #  i = 0
          #  while Time.zone.now - last_response.created_at <= 1
          #    sleep 1 - (Time.zone.now - last_response.created_at)
          #    i += 1
          #    if i > 10
          #      raise "timeout"
          #    end
          #  end
          #end

          # Get XML response file from Amazon Web Service
          #doc = nil
          response = APICache.get(amazon_url)
          #open(response){|f|
          #  doc = REXML::Document.new(f)
          #}
          # Save XML response file
          #if self.manifestation_api_response
          #  self.manifestation_api_response.update_attributes({:body => doc.to_s})
          #else
          #  xmlfile = AawsResponse.new(:body => doc.to_s)
          #  self.manifestation_api_response = xmlfile
          #  self.manifestation_api_response.save
          #end
        else
          raise "no isbn"
        end
      #end
    end
    
    def amazon_book_jacket
      response = access_amazon
      self.reload
      doc = REXML::Document.new(response)
      r = Array.new
      r = REXML::XPath.match(doc, '/ItemLookupResponse/Items/Item/')
      bookjacket = {}
      bookjacket['url'] = REXML::XPath.first(r[0], 'MediumImage/URL/text()').to_s
      bookjacket['width'] = REXML::XPath.first(r[0], 'MediumImage/Width/text()').to_s.to_i
      bookjacket['height'] = REXML::XPath.first(r[0], 'MediumImage/Height/text()').to_s.to_i
      bookjacket['asin'] = REXML::XPath.first(r[0], 'ASIN/text()').to_s

      if bookjacket['url'].blank?
        raise "Can't get bookjacket"
      end
      return bookjacket

    rescue
      bookjacket = {'url' => 'unknown_resource.png', 'width' => '100', 'height' => '100'}
    end

    def amazon_customer_reviews
      reviews = []
      doc = REXML::Document.new(self.access_amazon)
      reviews = []
      doc.elements.each('/ItemLookupResponse/Items/Item/CustomerReviews/Review') do |item|
        reviews << item
      end

      comments = []
      reviews.each do |review|
        r = {}
        r[:date] =  review.elements['Date/text()'].to_s
        r[:summary] =  review.elements['Summary/text()'].to_s
        r[:content] =  review.elements['Content/text()'].to_s
        comments << r
      end
      return comments
    rescue
      []
    end

  end
end
