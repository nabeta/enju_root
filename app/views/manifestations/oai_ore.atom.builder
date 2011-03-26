xml.instruct! :xml, :version=>"1.0"
xml.entry('xmlns' => "http://www.w3.org/2005/Atom"){
  xml.link :rel => 'alternate', :href => manifestation_url(@manifestation)
  xml.link :rel => 'self', :href => manifestation_url(@manifestation, :format => :atom)
  xml.link :rel => 'http://www.openarchives.org/ore/terms/describes', :href => manifestation_url(@manifestation)
  xml.id "tag:#{request.host},2008:#{@manifestation.class}/#{@manifestation.id}"
  xml.source do
    xml.author do
      xml.name LibraryGroup.site_config.name
      xml.uri LibraryGroup.site_config.url
    end
    xml.id "tag:#{request.host},2008:#{LibraryGroup.site_config.class}"
    xml.updated @manifestation.updated_at.utc.iso8601
    xml.title LibraryGroup.site_config.name
  end
  xml.published Time.zone.now.utc.iso8601
  xml.updated @manifestation.updated_at.utc.iso8601
  # TODO: ライセンスの指定と管理
  #xml.link :rel => 'license', :type='application/rdf+xml', :href => 'http://creativecommons.org/licenses/by-nc/2.5/rdf'
  #xml.rights 'This Resource Map is available under the Creative Commons Attribution-Noncommercial 2.5 Generic license'
  xml.title @manifestation.original_title
  @manifestation.creators.each do |creator|
    xml.author do
      xml.name creator.full_name
    end
  end
  xml.category :term => @manifestation.created_at.utc.iso8601, :scheme => 'http://www.openarchives.org/ore/atom/created'
  xml.category :term => @manifestation.updated_at.utc.iso8601, :scheme => 'http://www.openarchives.org/ore/atom/modified'
  xml.category :term => 'http://www.openarchives.org/ore/terms/Aggregation', :label => 'Aggregation', :scheme => 'http://www.openarchives.org/ore/terms/'
}
