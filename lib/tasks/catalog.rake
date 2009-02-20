require 'rake'
require 'active_record/fixtures'
require "#{File.dirname(__FILE__)}/../../config/environment.rb"

namespace :catalog do
  desc 'Load initial database fixtures.'
  task :setup do
    if User.administrators.blank?
      puts 'Loading fixtures...'
      Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end

      user = User.new
      user.patron = Patron.find(1)
      print "Enter new administrator login name: "
      user.login = $stdin.gets.chop
      print "Enter new administrator email address: "
      user.email = $stdin.gets.chop
      print "Enter new administrator password: "
      system "stty -echo"
      user.password = $stdin.gets.chop
      system "stty echo"
      puts
      print "Confirm administrator password: "
      system "stty -echo"
      user.password_confirmation = $stdin.gets.chop
      system "stty echo"
      puts
      if user.password != user.password_confirmation
        puts "Password mismatch!"
        exit
      end
      puts "Saving user information..."

      user.user_group = UserGroup.find(1)
      user.library = Library.find(1)
      user.user_number = '0'
      user.roles << Role.find_by_name('Administrator')

      begin
        user.activate
        puts 'Administrator account created.'
      rescue
        puts $!
        exit
      end

      puts 'Inititalized successfully.'
    else
      puts 'It seems that you have imported initial data.'
    end
  end

  desc 'Expire sessions.'
  task :expire_session do
    expire_sessions(1.week.from_now)
    puts "expired sessions!"
  end

  private

  def send_messages(args = nil)
    MessageQueue.not_sent.each do |queue|
      queue.send_message
    end
  end

  def fetch_feeds(args = nil)
    require 'action_controller/integration'
    app = ActionController::Integration::Session.new
    app.host = LIBRARY_WEB_HOSTNAME
    NewsFeed.find(:all).each do |news_feed|
      news_feed.force_reload
    end
    app.get "/news_feeds?mode=clear_cache"
  end

  def expire_aaws_responses(args = nil)
    AawsResponse.delete_all(['created_at < ?', 30.days.from_now])
  end

  def expire_reservations(args = nil)
    reservations = Reserve.will_expire(Time.zone.now.beginning_of_day)
    reservations.each do |reserve|
      reserve.aasm_expire!
      reserve.send_message('expired')
    end
    Reserve.send_message_to_patrons('expired') unless reservations.blank?
  end

  def expire_baskets(args = nil)
    Basket.will_expire(Time.zone.now.beginning_of_day).destroy_all
  end

  def expire_sessions(date)
    Session.sweep(date)
  end

  def import_patrons
    ImportedPatronFile.not_imported.each do |file|
      file.import
    end
  end

  def import_events
    ImportedEventFile.not_imported.each do |file|
      file.import
    end
  end

  def import_resources
    ImportedResourceFile.not_imported.each do |file|
      file.import
    end
  end

  def culculate_checkouts_count(from_date, to_date)
    manifestation_stat = CheckoutStat.create(:from_date => from_date, :to_date => to_date)
    manifestation_stat.culculate_manifestations_count
  end

  def culculate_bookmarks_count(from_date, to_date)
    bookmark_stat = BookmarkStat.create(:from_date => from_date, :to_date => to_date)
    bookmark_stat.culculate_bookmarks_count
  end
end
