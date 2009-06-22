require 'wcapi'
require 'kakasi'
require 'enju_worldcat'
ActiveRecord::Base.send :include, EnjuWorldcat
