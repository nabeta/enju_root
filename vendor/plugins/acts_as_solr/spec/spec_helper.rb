ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'active_record'
require 'active_record/fixtures'

gem 'rspec'
require 'spec'

$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
$: << File.expand_path(File.dirname(__FILE__) + '/../test/models')


RAILS_ROOT = File.dirname(__FILE__) unless defined? RAILS_ROOT
RAILS_ENV  = 'test' unless defined? RAILS_ENV

require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/../lib/acts_as_solr'

models_dir = File.join(File.dirname( __FILE__ ), '/../test/models')
Dir[ models_dir + '/*.rb'].each { |m| require m }