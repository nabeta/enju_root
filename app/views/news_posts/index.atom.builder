atom_feed(:url => formatted_news_posts_url(:atom)) do |feed|
  feed.title("#{@library_group.name} search results")
  feed.updated(@news_posts.first ? @news_posts.first.created_at : Time.zone.now)

  for news_post in @news_posts
    feed.entry(news_post) do |entry|
      entry.title(news_post.title)
      entry.author(news_post.user.login)
    end
  end
end
