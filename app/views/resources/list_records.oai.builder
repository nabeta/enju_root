def request_attr(prefix = 'oai_dc')
  from_time = @from_time.utc.iso8601 if @from_time
  until_time = @until_time.utc.iso8601 if @until_time
  attribute = {:metadataPrefix => prefix, :verb => 'ListRecords'}
  attribute.merge(:from => from_time) if from_time
  attribute.merge(:until => until_time) if until_time
  attribute
end

xml.instruct! :xml, :version=>"1.0"
xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :oai), request_attr('oai_dc')
  xml.ListRecords do
    @resources.each do |resource|
      xml.record do
        xml.header do
          xml.identifier resource_url(resource)
          xml.datestamp resource.updated_at.utc.iso8601
        end
        xml.metadata do
          xml.tag! "oai_dc:dc",
            "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd",
            "xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
            "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
            xml.tag! "dc:title", resource_url(resource)
          end
        end
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + Resource.per_page < @resources.total_entries
        xml.resumptionToken @resumption[:token], :completeListSize => @resources.total_entries, :cursor => @resumption[:cursor], :expirationDate => @resumption[:expired_at]
      end
    end
  end
end
