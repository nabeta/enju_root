xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
        'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
        'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    xml.title "#{@library_group.name} search results"
    xml.link "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => nil))}"
    xml.description "Project Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language I18n.default_locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => "rss"))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => "#{request.protocol}#{request.host_with_port}"
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "#{request.protocol}#{request.host_with_port}/page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @manifestations.offset + 1
      xml.tag! "opensearch:itemsPerPage", @manifestations.per_page
      xml.tag! "opensearch:Query", :role => 'request', :searchTerms => h(params[:query]), :startPage => (h(params[:page]) || 1)
    end
    if @manifestations
      for manifestation in @manifestations
        xml.item do
          xml.title h(manifestation.original_title)
          # rfc822
          xml.pubDate h(manifestation.created_at.rfc2822)
          xml.link "#{request.protocol}#{request.host_with_port}" + manifestation_path(manifestation)
          xml.guid "#{request.protocol}#{request.host_with_port}" + manifestation_path(manifestation), :isPermaLink => "true"
          xml.description do
            xml.expressions do
              manifestation.expressions.each do |expression|
                xml.work do 
                  xml.title h(expression.work.original_title)
                  xml.authors do
                    expression.work.patrons.each do |patron|
                      xml.author h(patron.full_name)
                    end
                  end
                end
                xml.title h(expression.original_title)
                expression.patrons.each do |patron|
                  xml.editor h(patron.full_name)
                end
              end
            end
          end
          manifestation.tags.each do |tag|
            xml.category h(tag)
          end
        end
      end
    end
  }
}
