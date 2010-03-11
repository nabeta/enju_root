# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test_helper'
$:.unshift File.join(File.dirname(__FILE__),'..','lib')


class SrwControllerTest < ActionController::TestCase
  PARAMS = <<EOB
    {
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
#          "sortKeys"=>"title_text,0",
          "query"=>"title=ruby"}},
      "Header"=>nil}}
EOB

  def setup
    @params = eval(PARAMS)
  end

  def test_srw_xml_post
    post :index, @params
    assert_response :success
    assert_template('srw/index.xml.builder')
  end

  def test_srw_error
    @params["Envelope"]["Body"]["searchRetrieveRequest"].delete "query"
    post :index, @params
    assert_response :success
    assert_template('srw/error.xml')
  end
end
