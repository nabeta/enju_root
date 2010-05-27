require 'twitter'
require 'enju_twitter'
ActiveRecord::Base.send :include, EnjuTwitter
