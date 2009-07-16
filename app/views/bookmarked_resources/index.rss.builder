xml.instruct! :xml, :version=>"1.0" 
xml.rss('version' => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom' => "http://www.w3.org/2005/Atom"){
  xml.channel{
    if @user
      xml.title t('bookmark.user_bookmark', :login_user_name => @user.login)
      xml.link "#{request.protocol}#{request.host_with_port}" + user_bookmarked_resources_path(@user.login)
    else
      xml.title "Bookmarks at #{@library_group.display_name.localize}"
      xml.link "#{request.protocol}#{request.host_with_port}" + bookmarked_resources_path
    end
    xml.description "Project Next-L Enju, an open source integrated library system developed by Project Next-L"
    xml.language @locale
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'self', :href => "#{request.protocol}#{request.host_with_port}#{url_for(params.merge(:format => :rss))}"
    xml.tag! "atom:link", :rel => 'alternate', :href => "#{request.protocol}#{request.host_with_port}"
    #xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/public_page/opensearch"
    unless params[:query].blank?
      xml.tag! "opensearch:totalResults", @count[:query_result]
      xml.tag! "opensearch:startIndex", @bookmarked_resources.offset + 1
      xml.tag! "opensearch:itemsPerPage", @bookmarked_resources.per_page
      #xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:query], :startPage => (params[:page] || 1)
    end
    for bookmarked_resource in @bookmarked_resources
      xml.item do
        xml.title h(bookmarked_resource.original_title)
        #xml.description(bookmark.title)
        # rfc822
        xml.pubDate bookmarked_resource.created_at.rfc2822
        xml.link manifestation_url(bookmarked_resource)
        xml.guid manifestation_url(bookmarked_resource), :isPermaLink => "true"
        bookmarked_resource.tags.each do |tag|
          xml.category(tag)
        end
      end
    end
  }
}
