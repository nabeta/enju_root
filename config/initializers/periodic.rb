scheduler = Rufus::Scheduler.start_new

scheduler.cron "0 4 * * *" do
  user_checkout_stat = UserCheckoutStat.create(:from_date => from_date, :to_date => to_date)
  user_checkout_stat.culculate_users_count
  manifestation_checkout_stat = ManifestationCheckoutStat.create(:from_date => from_date, :to_date => to_date)
  manifestation_checkout_stat.culculate_manifestations_count
  user_reserve_stat = UserReserveStat.create(:from_date => from_date, :to_date => to_date)
  user_reserve_stat.culculate_users_count
  manifestation_reserve_stat = ManifestationReserveStat.create(:from_date => from_date, :to_date => to_date)
  manifestation_reserve_stat.culculate_manifestations_count
  bookmark_stat = BookmarkStat.create(:from_date => from_date, :to_date => to_date)
  bookmark_stat.culculate_bookmarks_count
end
