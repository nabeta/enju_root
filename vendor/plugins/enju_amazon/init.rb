require 'enju_amazon'
require 'aaws_response'
ActiveRecord::Base.send :include, EnjuAmazon
ActionView::Base.send :include, EnjuAmazonHelper
