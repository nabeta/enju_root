xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :oai), :verb => "ListIdentifiers", :metadataPrefix => "oai_dc"
  xml.ListIdentifiers do
    @resources.each do |resource|
      xml.header do
        xml.identifier resource_url(resource)
        xml.datestamp resource.updated_at.utc.iso8601
        xml.setSpec resource.manifestation.series_statement.id if resource.manifestation.try(:series_statement)
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + @resources.per_page < @resources.total_entries
        xml.resumptionToken @resumption[:token], :completeListSize => @resources.total_entries, :cursor => @resumption[:cursor], :expirationDate => @resumption[:expired_at]
      end
    end
  end
end
