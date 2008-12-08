#!/usr/bin/ruby
ENV['RAILS_ENV'] ||= 'production'

require File.join(File.dirname(__FILE__), '../config/environment')

reindex_num = $*[0] ||= 500
start_num = $*[1] ||= 1

reindex_num = reindex_num.to_i
start_num = start_num.to_i

classes = [Work, Expression, Manifestation, Item, Subject, Patron, User, Classification, Event, Subscription, PurchaseRequest, Question]

classes.each do |obj|
  end_num = 0
  ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => "type_t:#{obj}"))
  obj.rebuild_solr_index(reindex_num) do |resource, options|
    end_num += reindex_num
    resource.find(:all, options.merge({:conditions => "id >= #{start_num} AND id <= #{end_num}", :order => "id"})) 
  end
  obj.solr_optimize
end
