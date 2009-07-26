module EnjuAmazonHelper
  def amazon_link(country = COUNTRY_CODE, asin = nil)
    return nil if asin.blank?
    case country
    when 'ca'
      url = "http://www.amazon.ca/dp/"
    when 'de'
      url = "http://www.amazon.de/"
    when 'fr'
      url = "http://www.amazon.fr/"
    when 'jp'
      url = "http://www.amazon.co.jp/"
    when 'uk'
      url = "http://www.amazon.co.uk/"
    when 'us'
      url = "http://www.amazon.com/"
    else
      url = "http://www.amazon.com/"
    end
    "#{url}dp/#{asin}"
  end

end
