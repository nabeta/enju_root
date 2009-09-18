class NewsFeedSweeper < ActionController::Caching::Sweeper
  observe NewsFeed
  def after_save(record)
    expire_fragment(:controller => :news_feeds, :action => :index, :id => record.id, :action_suffix => 'title')
  end

  def after_destroy(record)
    after_save(record)
  end
end
