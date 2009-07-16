class PublicPageController < ApplicationController
  def index
    if logged_in?
      redirect_to user_url(current_user.login)
    end
    @numdocs = Manifestation.cached_numdocs
    # TODO: タグ下限の設定
    @tags = Tag.find(:all, :limit => 50, :order => 'taggings_count DESC')
    @manifestation = Manifestation.pickup
    @news_feeds = LibraryGroup.site_config.news_feeds rescue nil
  end

  def screen_shot
    thumb = open(params[:url])
    #file = Tempfile.new('thumb')
    #file.puts thumb.read
    #file.close
    #mime = MIME.check_magics(file.path)
    send_file thumb.path, :filename => File.basename(thumb.path), :type => thumb.content_type, :disposition => 'inline'
    thumb.close
  end

  def msie_acceralator
    render :layout => false
  end

  def opensearch
    render :layout => false
  end

end
