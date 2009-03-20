scheduler = Rufus::Scheduler.start_new

scheduler.every '10s' do
  Rails.logger.info('hoge')
  Rails.logger.flush
end

scheduler.cron "0 4 * * *" do
  manifestation_stat = CheckoutStat.create(:from_date => from_date, :to_date => to_date)
  manifestation_stat.culculate_manifestations_count
  bookmark_stat = BookmarkStat.create(:from_date => from_date, :to_date => to_date)
  bookmark_stat.culculate_bookmarks_count
end
