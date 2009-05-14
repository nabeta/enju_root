atom_feed(:url => news_posts_url(:format => :atom)) do |feed|
  feed.title t('news_post.library_group_news_post', :library_group_name => @library_group.display_name.localize)
  feed.updated(@news_posts.first ? @news_posts.first.created_at : Time.zone.now)

  for news_post in @news_posts
    feed.entry(news_post) do |entry|
      entry.title(news_post.title)
      entry.author(news_post.user.login)
    end
  end
end
