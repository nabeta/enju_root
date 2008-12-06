require 'rubygems'
require 'spec'
require 'active_record'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'

current_dir = File.dirname(__FILE__)
$LOAD_PATH << "#{current_dir}/vendor/will_paginate/lib"
$LOAD_PATH << "#{current_dir}/vendor/acts_as_solr/lib"
require 'will_paginate'
require 'acts_as_solr'
 
config = YAML::load(IO.read(current_dir + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(current_dir + "/debug.log")
ActiveRecord::Base.establish_connection(config['wpaas_test'])
load(current_dir + "/schema.rb")

require "#{current_dir}/../lib/will_paginate_acts_as_solr"
require "#{current_dir}/some_model"