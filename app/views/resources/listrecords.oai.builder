xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :oai), :verb => "ListRecords", :from => @start_at, :metadataPrefix => "oai_dc"
  xml.ListRecords do
    @resources.each do |resource|
      xml.record do
        xml.header do
          xml.identifier resource_url(resource)
          xml.datestamp resource.updated_at.utc.iso8601
        end
        xml.metadata resource.dcndl_xml
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + Resource.per_page < @resources.total_entries
        xml.resumptionToken @resumption[:token], :completeListSize => @resources.total_entries, :cursor => @resumption[:cursor], :expirationDate => @resumption[:expired_at]
      end
    end
  end
end
