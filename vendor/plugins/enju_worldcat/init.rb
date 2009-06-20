require 'wcapi'
require 'enju_worldcat'
ActiveRecord::Base.send :include, EnjuWorldcat
