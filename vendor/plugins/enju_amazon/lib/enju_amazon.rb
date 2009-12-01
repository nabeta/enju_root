module EnjuAmazon
# Choose a locale from 'ca', 'de', 'fr', 'jp', 'uk', 'us'
#AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
  case COUNTRY_CODE
  when 'ca'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.ca'
  when 'de'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.de'
  when 'fr'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.fr'
  when 'jp'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.jp'
  when 'uk'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.uk'
  when 'us'
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
  else
    AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
  end

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
      raise "Access key is not set" if AMAZON_ACCESS_KEY == 'REPLACE_WITH_YOUR_AMAZON_KEY'
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
      raise "Access key is not set" if AMAZON_ACCESS_KEY == 'REPLACE_WITH_YOUR_AMAZON_KEY'
      url = "http://#{BOOKMARK_HOSTNAME}:#{BOOKMARK_PORT_NUMBER}/manifestations/#{self.id}.xml?api=amazon"
      Rails.cache.fetch("manifestation_amazon_response_#{self.id}"){open(url).read}
    end
    
    def amazon_book_jacket
      response = amazon
      doc = Nokogiri::XML(response)
      bookjacket = {}
      bookjacket['url'] = doc.at(:Item).at('MediumImage/URL').inner_text
      bookjacket['width'] = doc.at(:Item).at('MediumImage/Width').inner_text.to_i
      bookjacket['height'] = doc.at(:Item).at('MediumImage/Height').inner_text.to_i
      bookjacket['asin'] = doc.at(:Item).at('ASIN').inner_text

      if bookjacket['url'].blank?
        raise "Can't get bookjacket"
      end
      return bookjacket

    rescue
      bookjacket = {'url' => 'unknown_resource.png', 'width' => '100', 'height' => '100'}
    end

    def amazon_customer_reviews
      reviews = []
      doc = Nokogiri::XML(self.amazon)
      reviews = []
      doc.at(:Item).search('Review') do |item|
        reviews << item
      end

      comments = []
      reviews.each do |review|
        r = {}
        r[:date] =  review.at('Date').inner_text
        r[:summary] =  review.at('Summary').inner_text
        r[:content] =  review.at('Content').inner_text
        comments << r
      end
      return comments
    rescue
      []
    end

  end
end
