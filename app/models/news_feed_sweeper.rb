class NewsFeedSweeper < ActionController::Caching::Sweeper
  observe NewsFeed
  def after_save(record)
    expire_fragment(:controller => :news_feeds, :action => :index, :action_suffix => 'list')
  end

  def after_destroy(record)
    after_save(record)
  end

end
