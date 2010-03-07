# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'test_helper'
$:.unshift File.join(File.dirname(__FILE__),'..','lib')


class SrwControllerTest < ActionController::TestCase
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
  
  def test_srw_xml_post
    post :index, :body => XML
    assert_response :success
    assert_template('srw/index.xml.builder')
  end

  def test_srw_error
    error_xml = XML.sub(/^.+query.+$/, '')
    post :index, :body => error_xml
    assert_response :success
    assert_template('srw/error.xml')
  end
end
