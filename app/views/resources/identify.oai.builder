xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request resources_url(:format => :xml), :verb => "Identify"
  xml.Identify do
    xml.repositoryName LibraryGroup.site_config.name
    xml.baseURL resources_url(:format => :oai)
    xml.protocolVersion "2.0"
    xml.granularity "YYYY-MM-DDThh:mm:ssZ"
    xml.ealiestTimestamp Resource.last.created_at.utc.iso8601 if Resource.last
    xml.adminEmail LibraryGroup.site_config.email
  end
end
