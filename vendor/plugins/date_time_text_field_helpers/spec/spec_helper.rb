$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

ENV['RAILS_ENV'] = 'test'
RAILS_ROOT = File.dirname(__FILE__)

require 'rubygems'
require 'spec'

vendored_rails = File.dirname(__FILE__) + '/../../../../vendor/rails'

if vendored = File.exists?(vendored_rails)
  Dir.glob(vendored_rails + "/**/lib").each { |dir| $:.unshift dir }
else
  if ENV['VERSION']
    gem 'rails', ENV['VERSION']
  else
    begin
     require 'ginger'
    rescue LoadError
    end
    gem 'rails'
  end
end

require 'rails/version'
require 'active_support'
require 'action_controller'
require 'action_view'

require 'spec/rails'

require 'date_time_text_field_helpers'

Spec::Runner.configure do |config|
  config.include Spec::Rails::Matchers
end
