# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :path, RAILS_ROOT
set :environment, :production
set :cron_log, "#{RAILS_ROOT}/log/cron_log.log"

every 5.minute do
  runner "Session.expire; MessageQueue.send_messages"
end

every 1.hour do
  runner "Advertisement.expire_cache"
end

every 1.day, :at => '0:00 am' do
  runner "Reserve.expire; Basket.expire; NewsFeed.fetch_feeds"
end

every 1.day, :at => '1:00 am' do
  runner "UserCheckoutStat.calculate_stat; UserReserveStat.calculate_stat; ManifestationCheckoutStat.calculate_stat; ManifestationReserveStat.calculate_stat; BookmarkStat.calculate_stat"
end

every 1.hour do
  runner "ImportedPatronFile.import; ImportedEventFile.import; ImportedResourceFile.import; Rails.cache.delete('Manifestation.search.total')"
end

every 1.day, :at => '3:00 am' do
  rake "enju:reindex"
  #runner "LibraryGroup.solr_reindex(500)"
end

every 1.day, :at => '9:00 am' do
  runner "Checkout.send_due_date_notification(1); Checkout.send_overdue_notification"
end
