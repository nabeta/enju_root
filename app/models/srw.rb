require 'forwardable'
#require 'rubygems'
require 'nokogiri'
require 'sru'

class Srw
  extend Forwardable

  def initialize(xml)
    @params = {}
    doc = Nokogiri(xml)
    doc.at('/soapenv:Envelope/soapenv:Body/srw:searchRetrieveRequest').children.each do |prm|
      @params[prm.name.to_sym] = prm.child.text if prm.child
    end
    @sru = Sru.new(@params)
  end
  
  def_delegators :@sru, :search, :sort_by, :cql, :version,:packing
  def_delegators :@sru, :number_of_records, :next_record_position, :extra_response_data
end


#if $PROGRAM_NAME == __FILE__
#  require 'srw_test'
#end
