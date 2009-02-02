# http://d.hatena.ne.jp/donghai821/20080909/1220961815
class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def page_link(page, text, attributes = {})
    @template.link_to_remote text, remote_url_for(page), attributes
  end

  protected
  def remote_url_for(page)
    { :url => url_for(page),
      :update => @options[:update],
      :method => @options[:method] }
  end
end
