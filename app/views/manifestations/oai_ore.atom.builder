xml.instruct! :xml, :version=>"1.0"
xml.entry('xmlns' => "http://www.w3.org/2005/Atom"){
  xml.link :rel => 'alternate', :href => manifestation_url(@manifestation)
  xml.link :rel => 'self', :href => manifestation_url(@manifestation, :format => :atom)
  xml.link :rel => 'http://www.openarchives.org/ore/terms/describes', :href => manifestation_url(@manifestation)
  xml.id "tag:#{request.host},2008:#{@manifestation.class}/#{@manifestation.id}"
  xml.title LibraryGroup.config.name
  xml.source do
    xml.author do
      xml.name LibraryGroup.config.name
      xml.uri LibraryGroup.url
    end
    xml.id "tag:#{request.host},2008:#{LibraryGroup.config.class}"
    xml.updated @manifestation.updated_at.iso8601
    xml.title LibraryGroup.config.name
  end
  xml.published Time.zone.now.iso8601
  xml.updated @manifestation.updated_at.iso8601
  # TODO: ライセンスの指定と管理
  #xml.link :rel => 'license', :type='application/rdf+xml', :href => 'http://creativecommons.org/licenses/by-nc/2.5/rdf'
  #xml.rights 'This Resource Map is available under the Creative Commons Attribution-Noncommercial 2.5 Generic license'
}
