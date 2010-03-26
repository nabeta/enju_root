xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :oai), :verb => "GetRecord"
  xml.GetRecord do
    xml.record do
      if @resource.deleted_at
        xml.header(:status => 'deleted') do
          xml.identifier @resource.oai_identifier
          xml.datestamp @resource.updated_at.utc.iso8601
          xml.setSpec @resource.manifestation.series_statement.id if @resource.manifestation.try(:series_statement)
        end
      else
        xml.header do
          xml.identifier @resource.oai_identifier
          xml.datestamp @resource.updated_at.utc.iso8601
          xml.setSpec @resource.manifestation.series_statement.id if @resource.manifestation.try(:series_statement)
        end
      end
      xml.metadata do
        xml.tag! "oai_dc:dc",
          "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd",
          "xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
          xml.tag! "dc:title", resource_url(@resource)
        end
      end
    end
  end
end
