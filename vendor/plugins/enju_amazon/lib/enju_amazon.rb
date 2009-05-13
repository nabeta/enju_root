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
    def amazon
      unless self.isbn.blank?
        response = access_amazon_proxy
      end
    end

    def access_amazon
      unless self.isbn.blank?
        timestamp = CGI.escape(Time.now.utc.iso8601)
        query = [
          "AWSAccessKeyId=#{AMAZON_ACCESS_KEY}",
          "IdType=ISBN",
          "ItemId=#{self.isbn}",
          "Operation=ItemLookup",
          "ResponseGroup=Images%2CReviews",
          "SearchIndex=Books",
          "Service=AWSECommerceService",
          "Timestamp=#{timestamp}",
          "Version=2009-01-06"
          ].join("&")
        message = ["GET", AMAZON_AWS_HOSTNAME, "/onca/xml", query].join("\n")
        hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, AMAZON_SECRET_ACCESS_KEY, message)
        encoded_hash = CGI.escape(Base64.encode64(hash).strip)
        amazon_url = "https://#{AMAZON_AWS_HOSTNAME}/onca/xml?#{query}&Signature=#{encoded_hash}"

        file = open(amazon_url)
        body = file.read
        file.close

        return body
      else
        raise "no isbn"
      end
    end

    def access_amazon_proxy
      access_url = "http://#{BOOKMARK_HOSTNAME}:#{BOOKMARK_PORT_NUMBER}/manifestations/#{self.id}.xml?api=amazon"
      APICache.get(access_url)
    end
    
    def amazon_book_jacket
      response = amazon
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
      doc = REXML::Document.new(self.amazon)
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
