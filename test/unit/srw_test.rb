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
  PARAMS = {"action"=>"index",
    "controller"=>"srw",
    "Envelope"=>
      {"Body"=>
        {"searchRetrieveRequest"=>
          {"comment"=>[nil, nil, nil, nil, nil, nil, nil, nil, nil],
          "recordXPath"=>"?",
          "extraRequestData"=>nil,
          "stylesheet"=>"?",
          "version"=>"1.1",
          "maximumRecords"=>"1",
          "recordPacking"=>"xml",
          "startRecord"=>"2",
          "recordSchema"=>"dcndl_porta",
          "resultSetTTL"=>"?",
          "sortKeys"=>"title,0",
          "query"=>"title=ruby"}.symbolize_keys}.symbolize_keys,
      "Header"=>nil}.symbolize_keys}.symbolize_keys

  def setup
    @srw = Srw.new(PARAMS[:Envelope])
  end

  def test_s_new
    assert_instance_of Srw, @srw
    assert_instance_of Sru, @srw.instance_variable_get(:@sru)
  end

  def test_parms
    assert_equal '1.1', @srw.version
    assert_equal 2, @srw.start
    assert_equal 1, @srw.maximum
    assert_equal 'xml', @srw.packing
    assert_equal 'dcndl_porta', @srw.schema
    assert_equal Hash[:order=>"desc", :sort_by=>"sort_title"], @srw.sort_by
    assert_instance_of Cql, @srw.cql
  end

  def test_delegator
    assert_respond_to @srw, :search
    assert_respond_to @srw, :sort_by
    assert_respond_to @srw, :cql
    assert_respond_to @srw, :version
    assert_respond_to @srw, :packing
    assert_respond_to @srw, :start
    assert_respond_to @srw, :maximum
    assert_respond_to @srw, :number_of_records
    assert_respond_to @srw, :next_record_position
    assert_respond_to @srw, :extra_response_data
  end
end
