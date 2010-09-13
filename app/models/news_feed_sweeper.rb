class NewsFeedSweeper < ActionController::Caching::Sweeper
  observe NewsFeed
  def after_save(record)
    Role.all.each do |role|
      expire_fragment(:controller => :news_feeds, :action => :index, :id => record.id, :page => 'title', :role => role.name)
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
