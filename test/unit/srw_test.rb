#require 'rubygems'
#require 'pp'
#require 'test/unit'
require 'sru'
#require 'sru_mocks'

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require File.dirname(__FILE__) + '/../test_helper'

require 'srw'

class SrwTest < ActiveSupport::TestCase
#class SrwTest < Test::Unit::TestCase
  XML = <<EOB
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:srw="http://www.loc.gov/zing/srw/">
   <soapenv:Header/>
   <soapenv:Body>
      <srw:searchRetrieveRequest>
         <srw:version>1.2</srw:version>
         <srw:query>title=ruby</srw:query>
         <srw:startRecord>1</srw:startRecord>
         <srw:maximumRecords>3</srw:maximumRecords>
         <srw:recordPacking>xml</srw:recordPacking>
         <srw:recordSchema>dcndl_porta</srw:recordSchema>
         <srw:recordXPath></srw:recordXPath>
         <srw:resultSetTTL></srw:resultSetTTL>
         <srw:sortKeys></srw:sortKeys>
         <srw:stylesheet></srw:stylesheet>
         <srw:extraRequestData/>
      </srw:searchRetrieveRequest>
   </soapenv:Body>
</soapenv:Envelope>
EOB

  def setup
    @srw = Srw.new(XML)
  end

  def test_s_new
    assert_instance_of Srw, @srw
    assert_instance_of Sru, @srw.instance_variable_get(:@sru)
  end

  def test_parms
    assert_equal '1.2', @srw.instance_variable_get(:@params)[:version]
    assert_equal 'title=ruby', @srw.instance_variable_get(:@params)[:query]
    assert_equal '1', @srw.instance_variable_get(:@params)[:startRecord]
    assert_equal '3', @srw.instance_variable_get(:@params)[:maximumRecords]
    assert_equal 'xml', @srw.instance_variable_get(:@params)[:recordPacking]
    assert_equal 'dcndl_porta', @srw.instance_variable_get(:@params)[:recordSchema]
    assert_nil @srw.instance_variable_get(:@params)[:sortKeys]
  end

  def test_delegator
    assert_respond_to @srw, :search
    assert_respond_to @srw, :sort_by
    assert_respond_to @srw, :cql
    assert_respond_to @srw, :version
    assert_respond_to @srw, :packing
    assert_respond_to @srw, :number_of_records
    assert_respond_to @srw, :next_record_position
    assert_respond_to @srw, :extra_response_data
  end
end
