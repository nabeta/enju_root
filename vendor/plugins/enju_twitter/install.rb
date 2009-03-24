require 'fileutils'

config = File.dirname(__FILE__) + '/../../../config/initializers/enju_twitter.rb'
FileUtils.cp File.dirname(__FILE__) + '/enju_twitter_setting.rb', config unless File.exist?(config)
